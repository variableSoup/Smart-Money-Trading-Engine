import json
import gzip
from typing import Iterable, Union, IO, Any, Optional

def _maybe_open_out(out: Union[str, IO[bytes], IO[str]], gzip_enabled: bool):
    """Return a context manager that yields a writable binary file-like object."""
    if hasattr(out, "write"):
        # Assume already-open handle.
        return _NullCtx(out if "b" in getattr(out, "mode", "b") else _TextToBin(out))
    else:
        path = str(out)
        if gzip_enabled:
            return gzip.open(path, "wb")
        return open(path, "wb")

class _NullCtx:
    def __init__(self, obj): self.obj = obj
    def __enter__(self): return self.obj
    def __exit__(self, *exc): return False

class _TextToBin:
    """Wrap a text handle to expose a .write(bytes) interface."""
    def __init__(self, fh): self.fh = fh
    def write(self, b: bytes): self.fh.write(b.decode("utf-8"))

def _iter_json_array_from_string(s: str) -> Iterable[dict]:
    """Memory-efficient iteration over a JSON array string."""
    # Fast path if it's already a list of dicts as text but small enough:
    try:
        obj = json.loads(s)
        if isinstance(obj, list):
            for r in obj:
                if isinstance(r, dict):
                    yield r
                else:
                    raise ValueError("Array contains non-object items.")
            return
        raise ValueError("Provided JSON is not an array.")
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON: {e}") from e

def _iter_json_array_from_file(path: str) -> Iterable[dict]:
    """
    Stream a large JSON array from disk.
    Uses ijson if available; falls back to json.load (loads whole file).
    """
    try:
        import ijson  # type: ignore
        with open(path, "rb") as f:
            for obj in ijson.items(f, "item"):
                if not isinstance(obj, dict):
                    raise ValueError("Array contains non-object items.")
                yield obj
    except ImportError:
        # Fallback (not streaming)
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if not isinstance(data, list):
            raise ValueError("Provided JSON file is not an array.")
        for obj in data:
            if not isinstance(obj, dict):
                raise ValueError("Array contains non-object items.")
            yield obj

def _coerce_for_bq(record: dict, coerce_numeric: bool = False) -> dict:
    """
    Optional: coerce a few known fields so BigQuery autodetect picks numeric types.
    Leave as strings if you prefer exact ingestion.
    """
    if not coerce_numeric:
        return record

    out = dict(record)
    def to_float(x: Any) -> Any:
        try:
            return float(x)
        except (TypeError, ValueError):
            return x

    for key in ("Amount", "ExcessReturn", "PriceChange", "SPYChange"):
        if key in out:
            out[key] = to_float(out[key])

    # Dates are fine as ISO strings for BigQuery autodetect; no change needed.
    return out

def write_ndjson(
    source: Union[Iterable[dict], str],
    out: Union[str, IO[bytes], IO[str]],
    *,
    gzip_output: bool = False,
    coerce_numeric: bool = False,
) -> int:
    """
    Convert a JSON array (or iterable of dicts) to NDJSON for BigQuery.

    Parameters
    ----------
    source : 
        - iterable of dicts (e.g., requests.json())
        - JSON string containing an array
        - path to a .json file on disk
    out :
        - output file path ('.ndjson' or '.ndjson.gz' if gzip_output=True)
        - or an open file handle
    gzip_output : bool
        - if True, writes GZIP-compressed NDJSON
    coerce_numeric : bool
        - if True, attempts to cast 'Amount', 'ExcessReturn', 'PriceChange', 'SPYChange' to floats

    Returns
    -------
    int : number of records written
    """
    # Normalize source to an iterator of dicts
    iterator: Optional[Iterable[dict]] = None

    if isinstance(source, str):
        # Is it a path to a file or a JSON string? Heuristic: looks like a path if it exists on disk.
        import os
        if os.path.exists(source):
            iterator = _iter_json_array_from_file(source)
        else:
            iterator = _iter_json_array_from_string(source)
    else:
        # Assume it's an iterable of dicts
        iterator = source

    count = 0
    with _maybe_open_out(out, gzip_output) as fh:
        for rec in iterator:
            if not isinstance(rec, dict):
                raise ValueError("All items must be JSON objects.")
            rec = _coerce_for_bq(rec, coerce_numeric=coerce_numeric)
            line = json.dumps(rec, ensure_ascii=False, separators=(",", ":")) + "\n"
            fh.write(line.encode("utf-8"))
            count += 1
    return count
