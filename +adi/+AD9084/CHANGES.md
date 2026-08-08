# AD9084 Toolbox Change Log

Changes made to the HSCT Repo AD9084 class files relative to their original state.

---

## Tx.m

### Change 0 — Class was originally referencing AD9081 throughout
Every reference to `AD9084` in the current `Tx.m` originally said `AD9081`. This
affected the class inheritance, constructor super call, comments, devName strings,
and any other identifier containing the part number. The file was essentially a
copy of the AD9081 Tx class that had not yet been updated to AD9084.

Affected locations (now AD9084, originally AD9081):
- Line 1:   `classdef Tx < adi.AD9084.Base`
- Line ~2:  comment `adi.AD9084.Tx Transmit data from the AD9084...`
- Line ~3:  comment `The adi.AD9084.Tx System object...`
- Line ~4:  comment `complex data from the AD9084`
- Line ~6:  comment `tx = adi.AD9084.Tx;`
- Line ~7:  comment `tx = adi.AD9084.Tx('uri',...)`
- Line ~9:  hyperlink text and URL containing `AD9084`
- Line ~61: `devName = 'axi-ad9084-tx-hpc'`
- Line ~69: `obj = obj@adi.AD9084.Base(varargin{:})`

---


### Change 1 — Constructor: override `phyDevName`
**Constructor body, first line after super call**
- Before: (not present)
- After:  `obj.phyDevName = 'axi-ad9084-tx-hpc';`
- Reason: `Base.m` hardcodes `phyDevName = 'axi-ad9084-rx-hpc'` as the default.
  Without this override, `setupInit` fetches the RX device handle and tries to
  write TX-only attributes to it, causing attribute write failures.
  The override is done in the constructor body (not as a new property declaration)
  to avoid a MATLAB "property already defined in superclass" error.

---

### Change 2 — `ChannelNCOGainScales` disabled: AD9081 artifact, not supported on AD9084

`ChannelNCOGainScales` and all associated code were an artifact of the AD9081
class from which this file was derived. The `channel_nco_gain_scale` IIO
attribute does not exist on the AD9084, so all references have been commented
out rather than removed, in case they are needed for reference:

- **Property declaration** (in `properties` block):
  ```matlab
  % ChannelNCOGainScales = [1,1,1,1];
  ```
- **Constructor initialization**:
  ```matlab
  % obj.ChannelNCOGainScales = ones(1,obj.num_fine_attr_channels);
  ```
- **Property setter** (`set.ChannelNCOGainScales`):
  ```matlab
  % function set.ChannelNCOGainScales(obj, value)
  %     obj.CheckAndUpdateHWFloat(value,'ChannelNCOGainScales',...
  %         'channel_nco_gain_scale', obj.combinedDev, false);
  %     obj.ChannelNCOGainScales = value;
  % end
  ```
- **`setupInit` bulk write**:
  ```matlab
  % obj.CheckAndUpdateHWFloat(obj.ChannelNCOGainScales,...
  %     'ChannelNCOGainScales','channel_nco_gain_scale', ...
  %     combinedDev, false);
  ```

---

### Change 3 — `setupInit`: IIO device routing and `isOutput` flag
**`setupInit` method**
- Before: All attribute writes used `obj.phyDev` (= `axi-ad9084-tx-hpc`) with
  `isOutput = true`.
- After:  All attribute writes use `combinedDev` (= `axi-ad9084-rx-hpc`) with
  `isOutput = false`.
- Reason (two separate issues):

  **Issue A — Wrong device:**
  All NCO/gain/enable channel attributes (`out_voltage*_channel_nco_*` etc.) live
  on the combined `axi-ad9084-rx-hpc` IIO device, which hosts BOTH `in_voltage*`
  (RX) and `out_voltage*` (TX) sysfs channel attributes. The `axi-ad9084-tx-hpc`
  device is the DMA/DDS transport layer only and does not expose these attributes.

  **Issue B — Inverted `isOutput` flag:**
  The `iio_device_find_channel` wrapper in this MATLAB libiio binding has INVERTED
  `isOutput` logic (marked `%FIXME` in `+adi/+common/Attribute.m`):
    - Passing `true`  → finds INPUT  channels (`in_voltage*`)
    - Passing `false` → finds OUTPUT channels (`out_voltage*`)
  Since `channel_nco_gain_scale` only exists on TX output channels, passing `true`
  was always targeting the wrong channel and causing the attribute write to fail.
  NCO frequency/phase attributes exist on both in/out channels so those failures
  were masked until `channel_nco_gain_scale` was reached.

---

### Change 4 — PFIR and CFIR support added
Mirrors the same additions made to `Rx.m` (see Rx.m section below).

**Properties added:**
```matlab
% PFIR
EnablePFIRs = false;   % (Nontunable, Logical)
PFIRFilenames = '';    % (Nontunable)
% CFIR
EnableCFIRs = false;   % (Nontunable, Logical)
CFIRFilenames = '';    % (Nontunable)
```

**Set-method validators added:**
- `set.EnablePFIRs` — validates logical input
- `set.PFIRFilenames` — stores filename, calls `writePFIRFile()` if already connected
- `set.EnableCFIRs` — validates logical input
- `set.CFIRFilenames` — stores filename, calls `writeCFIRFile()` if already connected

**Protected methods added:**
- `writePFIRFile()` — reads `PFIRFilenames` and writes contents to the `pfilt_config`
  device attribute over libiio
- `writeCFIRFile()` — reads `CFIRFilenames` and writes contents to the `cfir_config`
  device attribute over libiio

**`setupInit` extended:**
```matlab
if obj.EnablePFIRs
    obj.writePFIRFile();
end
if obj.EnableCFIRs
    obj.writeCFIRFile();
end
```
Added before the DDS block so filters are programmed at connection time when `tx()`
is first called.

---

### Change 5 — NCO property setters: route to correct IIO device at runtime

**All 6 NCO property setters**

Change 3 fixed `setupInit` to write NCO attributes to the correct device
(`axi-ad9084-rx-hpc`) at connection time. However, the runtime property setters
— called when the user changes an NCO property *after* the object is already
connected — still targeted `obj.phyDev` (`axi-ad9084-tx-hpc`) with
`isOutput = true`. This meant any post-setup NCO update would silently write to
the wrong device.

**New property added:**
```matlab
properties (Nontunable, Hidden)
    ...
    combinedDev  % axi-ad9084-rx-hpc (NCO/PHY attrs for both RX and TX)
end
```

**`setupInit` now persists the handle:**
```matlab
combinedDev = getDev(obj, 'axi-ad9084-rx-hpc');
obj.combinedDev = combinedDev;
obj.phyDev  = getDev(obj, obj.phyDevName);  % tx-hpc (DDS/DMA)
```

**All active NCO setters updated:**
- `set.ChannelNCOFrequencies`
- `set.MainNCOFrequencies`
- `set.ChannelNCOPhases`
- `set.MainNCOPhases`
- `set.NCOEnables`

Note: `set.ChannelNCOGainScales` was also updated during this change but has
since been commented out entirely — see Change 2.

Each changed from:
```matlab
obj.CheckAndUpdateHW(value, ..., obj.phyDev, true);
```
To:
```matlab
obj.CheckAndUpdateHW(value, ..., obj.combinedDev, false);
```

This ensures runtime NCO updates are consistent with `setupInit` — targeting
`axi-ad9084-rx-hpc` with the correct inverted `isOutput` flag.

**Device handle summary:**

| Handle            | IIO Device            | Used for                                |
|-------------------|-----------------------|-----------------------------------------|
| `obj.phyDev`      | `axi-ad9084-tx-hpc`  | DDS tone control, TX DMA                |
| `obj.combinedDev` | `axi-ad9084-rx-hpc`  | NCO freq/phase/gain/enable (TX and RX)  |

---

### Change 6 — `num_dds_channels` corrected from 32 to 16

**Hidden property `num_dds_channels`**

- Before: `num_dds_channels = 32`
- After:  `num_dds_channels = 16`
- Reason: The constructor derives DDS array sizes and channel name lists from
  this value (`l = num_dds_channels/2` → `DDSFrequencies = zeros(2,l)`).
  With 32, `DDSUpdate` iterated `altvoltage0`–`altvoltage31`. The AD9084 FPGA
  DDS core only exposes 16 DDS channels (`altvoltage0`–`altvoltage15`), one
  pair of tones per TX I/Q channel (4 channels × 2 tones × 2 I/Q = 16).
  This caused a hard error at `altvoltage16`:
  ```
  Error using matlabshared.libiio.base/cstatusid
  Channel: altvoltage16 not found.
  ```
  The value 32 was inherited from the AD9081 class, which has 8 TX data
  channels rather than 4.

---

## Rx.m (new) vs Rx1.m (original)

`Rx1.m` is the original unmodified Rx class. `Rx.m` is the updated version used by
`filter_demo.m`. The filename `Rx` takes precedence in MATLAB's package resolution,
so `adi.AD9084.Rx` will always resolve to `Rx.m`.

### Difference 1 — CFIR properties added
**Present in Rx.m, absent in Rx1.m**
```matlab
properties (Nontunable, Logical)
    EnableCFIRs = false;
end
properties (Nontunable)
    CFIRFilenames = '';
end
```
- Reason: Adds user-facing controls to enable the CFIR filter and specify the
  coefficient file path, matching the existing PFIR pattern.

### Difference 2 — CFIR set-method validators added
**Present in Rx.m, absent in Rx1.m**
```matlab
function set.EnableCFIRs(obj, value)  ...  end
function set.CFIRFilenames(obj, value)  ...  end
```
- Reason: Validates inputs and triggers `writeCFIRFile()` immediately if already
  connected to hardware (same pattern as `set.PFIRFilenames`).

### Difference 3 — `writeFilterFile` renamed to `writePFIRFile`
**Rx1.m:** `function writeFilterFile(obj)`
**Rx.m:**  `function writePFIRFile(obj)`
- Reason: Renamed for clarity to distinguish it from the new `writeCFIRFile`.
  The `set.PFIRFilenames` setter was updated to call `obj.writePFIRFile()` accordingly.

### Difference 4 — `writeCFIRFile` method added
**Present in Rx.m, absent in Rx1.m**
```matlab
function writeCFIRFile(obj)
    % reads CFIRFilenames and writes contents to 'cfir_config' device attribute
end
```
- Reason: Sends the CFIR coefficient file to the hardware over libiio using the
  `cfir_config` sysfs attribute, same mechanism as PFIR uses `pfilt_config`.

### Difference 5 — `setupInit` CFIR block added
**Present in Rx.m, absent in Rx1.m**
```matlab
if obj.EnableCFIRs
    obj.writeCFIRFile();
end
```
- Reason: Ensures the CFIR filter is programmed to hardware at connection time
  (i.e. when `rx()` is first called), after the PFIR block.

---

## filter_demo.m

Demonstrates a complete AD9084 RX/TX configuration workflow with filter design and application. The script:

1. **Creates FIR filters** — Designs three example filters (Low-Pass, Band-Pass, High-Pass) using `fir1()` with configurable tap counts and cutoff frequencies
2. **Visualizes filters** — Optionally displays filter magnitude/phase responses using `fvtool` (toggled via `filtView` switch)
3. **Instantiates filter classes** — Uses the new `adi.AD9084.PFilt` and `adi.AD9084.CFIR` classes to wrap coefficients and generate configuration files (`pfir_auto.txt`, `cfir_auto.txt`)
4. **Creates RX object** — Configures an AD9084 receiver with CFIR filter enabled, NCO tuning, and sample frame settings
5. **Creates TX object** — Configures an AD9084 transmitter with DDS tone generation, NCO settings, and gain scaling


---

## PFilt.m

### Change 1 — Corrected `gain` and `scalar_gain` valid ranges per AD9084 UG

**`buildCatalogs` in `PFilt.m`**

**`gain` (shift gain):**
- Before: `{'0','6','12','18','24','-24','-18','-12'}` (included unsupported negative values)
- After:  `{'0','6','12','18','24'}`
- Reason: Per the AD9084 User Guide, the shift gain block supports 0dB to 24dB in
  6dB steps only. Negative dB values are not valid on this hardware.

**`scalar_gain`:**
- Before: `{'0','6','12','18','24','-24','-18','-12'}` (incorrect — was copied from gain)
- After:  `{'0','1','2', ..., '64'}` (integers 0–64, generated via `arrayfun(@num2str, 0:64, ...)`)
- Reason: Per the AD9084 UG, the scalar gain is a 6-bit unsigned integer representing
  a fractional multiplier N/64. Value 0 = silence (0/64), value 64 = unity (64/64 = 1).
  NOTE: Maximum scalar gain (64) and maximum shift gain (24dB) cannot be used
  simultaneously. Maximum achievable combined gain is (63/64) × 24dB.

Comments were also added to `buildCatalogs` citing the AD9084 UG.

### Change 2 — Fixed `real_data_mode_en` default and `real_n4` auto-inference

**Bug 1 — `real_data_mode_en` default mismatch (`defaultParams`)**
- Before: `'real_data_mode_en', 0`
- After:  `'real_data_mode_en', 1`
- Reason: The constructor argument default was already `= 1`, and all working
  pfir_auto.txt files show `real_data_mode_en: 1`. The `defaultParams` value of `0`
  was inconsistent and would produce incorrect filter files when params were
  rebuilt from defaults.

**Bug 2 — Auto mode inference used `real_n2` for 17–32 tap filters**
- Before: both the 9–16 and 17–32 tap branches set `toks = ["real_n2","real_n2"]`
- After:  the 17–32 tap branch now sets `toks = ["real_n4","real_n4"]`
- Reason: `real_n2` has N=16 max taps; a filter with 17–32 taps would pass
  auto-inference then immediately fail tap-length validation. `real_n4` (N=32)
  is the correct mode for that range.

**Cleanup — Dead code removed from `finalizeHeaderTokens`**
- `profTok` was computed but never used (the dest was always hardcoded to
  `"rx pfilt_all bank_0"`). Removed the dead `prof`/`profTok` logic and added
  a comment clarifying that PFIR dest does not use profile tokens (unlike CFIR).

---

## CFIR.m

### Change 1 — Corrected `gain` valid range per AD9084 UG

**`buildCatalogs` in `CFIR.m`**

- Before: `{'0','6','12','18','24','-24','-18','-12'}`
- After:  `{'-18','-12','-6','0','6','12'}`
- Reason: Per the AD9084 UG (Table 112 / CFIR section): "a gain adjustment block can
  be used to adjust the gain between -18 to +12 dB in 6 dB steps." The previous range
  was incorrect (copied from an unrelated source).

### Change 2 — Added `sparse_mode` parameter

**Constructor `options`, `defaultParams`, and `previewHeader`/`write`**

The AD9084 UG describes two CFIR operation modes:
- **Normal mode**: 16-tap complex FIR filter (`sparse_mode = 0`, default)
- **Sparse mode**: Up to 128 taps with only 16 non-zero taps, selectable anywhere
  in the impulse response (`sparse_mode = 1`). Useful for compensating long cable
  echoes without increasing non-zero tap count.

Added `sparse_mode` as a new boolean constructor parameter (0 or 1):
```matlab
cf = adi.AD9084.CFIR(taps, 'sparse_mode', 1);  % enable sparse mode
```

The field is written to the filter config file header as `sparse_mode: 0` or
`sparse_mode: 1`.

NOTE: `selection_mode: direct_regmap` is retained and is unrelated to CFIR sparse
mode — it controls NCO channel selection hopping (per UG: Direct SPI/HSCI profile
select). The two fields are independent.

### Change 3 — All five `selection_mode` options added

`buildCatalogs` previously only allowed `{'direct_regmap'}`. All five modes from the
AD9084 UG (`adi_apollo_cfir_profile_sel_mode_set` enum) are now valid:
- `direct_regmap` — Immediate hop via SPI write (default)
- `direct_gpio`   — Immediate hop on GPIO edge
- `trig_regmap`   — Scheduled hop via SPI, fires on next trigger
- `trig_gpio`     — Scheduled hop via GPIO, fires on next trigger
- `trig_auto`     — Automatic increment/decrement through profiles on trigger

### Change 4 — Tap count validation added

Constructor now validates `numel(taps)` before any other processing:
- Normal mode (`sparse_mode = 0`): max 16 taps
- Sparse mode (`sparse_mode = 1`): max 128 taps

An `error()` is raised immediately with a clear message if the count is exceeded.

### Change 5 — `complex_scalar` range validation added

`validateAll` now checks that both components of `complex_scalar` are integers in
`[-32768, 32767]` (16-bit signed), per the UG definition of `scalar_i`/`scalar_q`.
Previously any numeric pair would pass through silently.

### Change 6 — Removed dead `ingestParams` method

The `ingestParams` private method was never called anywhere in the class. Removed.

---

## Base.m

No changes made.

