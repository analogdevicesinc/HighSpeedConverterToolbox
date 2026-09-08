function ids = selectReadableAttributeChannelIDs(candidateIDs, readLengths, N)
%selectReadableAttributeChannelIDs Choose coarse-capable AD9081 channel IDs
%   IDS = selectReadableAttributeChannelIDs(CANDIDATEIDS, READLENGTHS, N)
%   returns the first N channel IDs from CANDIDATEIDS whose corresponding
%   READLENGTHS entry is positive (i.e. the coarse attribute read back a
%   value rather than returning an error). On the AD9081 hdl_2026_r1
%   datapath, main_* (coarse) attributes are exposed on only a subset of
%   the physical voltage channels, and those channels are not contiguous,
%   so channel selection must be driven by attribute readability rather
%   than a fixed stride.
%
%   This is a plain package function (no libiio superclass dependency) so
%   the selection logic can be unit tested without the libiio hardware
%   support package installed.
    assert(numel(candidateIDs) == numel(readLengths), ...
        'Candidate IDs and read lengths must have equal size');
    ids = candidateIDs(readLengths > 0);
    assert(numel(ids) >= N, ...
        'Not enough channels expose the requested AD9081 attribute');
    ids = ids(1:N);
end
