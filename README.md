# SBOM Generation with Syft

This repository contains scripts and tools for generating Software Bills of Materials (SBOMs) using Anchore's Syft tool.

## Overview

Software Bills of Materials (SBOMs) provide a comprehensive inventory of software components, dependencies, and metadata. This helps with:

- Security vulnerability tracking
- License compliance
- Supply chain risk management
- Software inventory management

## Prerequisites

### Option 1: Install Syft Binary (Recommended)

```bash
# Install via curl (Linux/macOS)
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Install via Homebrew (macOS)
brew install syft

# Install via package managers
# Debian/Ubuntu
sudo apt install syft

# RHEL/CentOS/Fedora
sudo dnf install syft
```

### Option 2: Using Go Run (if building from source)

```bash
# Clone and run Syft from source
git clone https://github.com/anchore/syft.git
cd syft
go run ./cmd/syft /path/to/your/software/directory

# Or with output format
go run ./cmd/syft /path/to/your/software/directory -o spdx-json
```

## Usage

### Automated SBOM Generation Script

The `generate_sboms.sh` script automatically generates SBOMs for multiple critical directories:

```bash
#!/bin/bash
directories=(
    "/usr/local/FM"
    "/usr/local/FN" 
    "/usr/local/nc/bin"
    "/usr/local/bin"
    "/usr/local/mongo"
    "/etc/elasticsearch"
    "/etc/kibana"
)

datetime=$(date +"%Y-%m-%d_%H-%M-%S")
output_dir="./sbom_reports"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

echo "Starting SBOM generation at $datetime"
echo "======================================="

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        filename="${output_dir}/nextcomputing_${dirname}_${datetime}-sbom.spdx.json"
        
        echo "Processing: $dir"
        if go run ./cmd/syft "$dir" -o spdx-json="${filename}"; then
            echo "✓ Generated SBOM for $dir -> $filename"
            # Optional: Show file size
            echo "  File size: $(du -h "$filename" | cut -f1)"
        else
            echo "✗ Failed to generate SBOM for $dir"
        fi
        echo ""
    else
        echo "⚠ Directory $dir does not exist, skipping..."
    fi
done

echo "SBOM generation completed!"
```

### Running the Script

1. Make the script executable:
   ```bash
   chmod +x generate_sboms.sh
   ```

2. Run the script:
   ```bash
   ./generate_sboms.sh
   ```

### Manual SBOM Generation

Generate SBOM for a single directory:

```bash
# Basic usage
syft /path/to/directory

# Generate SPDX JSON format
syft /path/to/directory -o spdx-json=output.spdx.json

# Generate multiple formats
syft /path/to/directory -o spdx-json=output.spdx.json -o table=output.txt
```

## Output Formats

Syft supports multiple output formats:

- **SPDX JSON** (`spdx-json`) - Industry standard format
- **SPDX Tag-Value** (`spdx-tag-value`) - SPDX text format  
- **CycloneDX JSON** (`cyclonedx-json`) - CycloneDX format
- **CycloneDX XML** (`cyclonedx-xml`) - CycloneDX XML format
- **Table** (`table`) - Human-readable table
- **Text** (`text`) - Simple text output
- **JSON** (`json`) - Syft native JSON format

## File Naming Convention

Generated SBOM files follow this naming pattern:
```
nextcomputing_{directory_name}_{YYYY-MM-DD_HH-MM-SS}-sbom.spdx.json
```

Example:
```
nextcomputing_bin_2025-08-07_15-46-05-sbom.spdx.json
```

## Monitored Directories

The script monitors these critical system directories:

| Directory | Purpose |
|-----------|---------|
| `/usr/local/FM` | NextComputing FM components |
| `/usr/local/FN` | NextComputing FN components |
| `/usr/local/nc/bin` | NextComputing binary tools |
| `/usr/local/bin` | System binaries and tools |
| `/usr/local/mongo` | MongoDB installation |
| `/etc/elasticsearch` | Elasticsearch configuration |
| `/etc/kibana` | Kibana configuration |

## Understanding SBOM Content

### Package Types Detected
- **Go modules** - Go dependencies and applications
- **Binary packages** - Compiled executables
- **System packages** - OS-level packages
- **Container images** - Docker/OCI images (if applicable)

### Key Information Included
- Package names and versions
- License information
- Security identifiers (CPEs)
- Package URLs (PURLs)
- File checksums (SHA1, SHA256)
- Dependency relationships

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   sudo ./generate_sboms.sh
   ```

2. **Syft Not Found**
   - Ensure Syft is installed and in PATH
   - Use full path to Syft binary if needed

3. **Go Module Not Found**
   - Ensure Go is installed and properly configured
   - Check GOPATH and GOROOT environment variables

4. **Empty or Missing Dependencies**
   - Some applications may not have detectable dependencies
   - Syft may require specific file permissions to analyze certain directories

### Verification

Verify generated SBOMs:

```bash
# Check SPDX format validity
syft validate output.spdx.json

# View SBOM contents in table format
syft convert output.spdx.json -o table
```

## Security Considerations

- **Sensitive Information**: SBOMs may contain system information - store securely
- **Regular Updates**: Generate SBOMs regularly to track changes
- **Access Control**: Limit access to SBOM files as they reveal system architecture
- **Vulnerability Scanning**: Use SBOMs with vulnerability databases for security analysis

## Integration

### CI/CD Pipeline Integration

```yaml
# Example GitHub Actions workflow
name: Generate SBOM
on: [push, pull_request]

jobs:
  sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Syft
        run: |
          curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
      - name: Generate SBOM
        run: |
          syft . -o spdx-json=sbom.spdx.json
      - name: Upload SBOM
        uses: actions/upload-artifact@v3
        with:
          name: sbom
          path: sbom.spdx.json
```

## Resources

- [Syft Documentation](https://github.com/anchore/syft)
- [SPDX Specification](https://spdx.dev/)
- [CycloneDX Specification](https://cyclonedx.org/)
- [NTIA SBOM Guidelines](https://www.ntia.doc.gov/page/software-bill-materials)

## License

This project follows the same license as the underlying software components. Review individual SBOM files for specific license information.
