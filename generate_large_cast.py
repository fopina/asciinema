#!/usr/bin/env python3
"""Generate a large asciicast v3 file for testing."""

import json
import sys

def generate_large_cast(output_file, target_size_mb=100):
    """Generate an asciicast v3 file of approximately target_size_mb."""

    # Header (v3 format)
    header = {
        "version": 3,
        "term": {
            "cols": 80,
            "rows": 24
        },
        "timestamp": 1704067200
    }

    # Sample output text - repeated to create large file
    sample_text = "This is a test line with some content to make the file larger. " * 10

    with open(output_file, 'w') as f:
        # Write header
        f.write(json.dumps(header) + '\n')

        current_size = f.tell()
        target_size = target_size_mb * 1024 * 1024
        time_offset = 0.001  # 1ms between events
        event_count = 0

        print(f"Generating {target_size_mb}MB cast file...", file=sys.stderr)

        while current_size < target_size:
            # Create an output event
            event = [time_offset, "o", sample_text + "\r\n"]
            f.write(json.dumps(event) + '\n')

            event_count += 1
            current_size = f.tell()

            # Progress indicator every 10MB
            if event_count % 100000 == 0:
                print(f"  Progress: {current_size / (1024 * 1024):.1f}MB ({event_count} events)", file=sys.stderr)

    actual_size_mb = current_size / (1024 * 1024)
    print(f"Generated {output_file}: {actual_size_mb:.2f}MB with {event_count} events", file=sys.stderr)

if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "large_test.cast"
    size_mb = int(sys.argv[2]) if len(sys.argv) > 2 else 100
    generate_large_cast(output, size_mb)
