"""Serve only an existing generated comparison copy, with a bounded local bind."""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, format, *args):
        # Browser diagnostics and capture manifests record failures. Avoid a
        # stdout request-log bottleneck while parallel font/modules load.
        pass


class Server(ThreadingHTTPServer):
    request_queue_size = 128


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("copy")
    parser.add_argument("--port", type=int, default=4174)
    args = parser.parse_args()
    root = Path(args.copy).resolve(strict=True)
    repo = Path(__file__).resolve().parents[3]
    allowed = (repo / "build/design-comparison").resolve()
    if not root.is_relative_to(allowed) or not (root / "comparison-manifest.json").is_file():
        raise SystemExit("Serve an existing generated comparison copy only.")
    with Server(("127.0.0.1", args.port), partial(Handler, directory=str(root))) as server:
        print(f"Comparison: http://127.0.0.1:{args.port} from {root}", flush=True)
        server.serve_forever()
