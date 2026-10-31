import pytest

from axon_host import AxonClient, Descriptor


class FakeRing:
    def __init__(self):
        self.pushed = []

    def push(self, desc):
        self.pushed.append(desc)
        return len(self.pushed)

    def wait(self, tag, timeout):
        return self.pushed[tag - 1].length


def test_submit_returns_bytes_moved():
    ring = FakeRing()
    assert AxonClient(ring).submit(Descriptor(0x1000, 0x2000, 4096)) == 4096


def test_rejects_unaligned_length():
    with pytest.raises(ValueError):
        AxonClient(FakeRing()).submit(Descriptor(0x1000, 0x2000, 6))
