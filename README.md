# QuicklyScope
Quickly find subdomains related to a given domain with the tools assetfinder, httprobe and gowitness.

## Usage
```
▶ ./quicklyscope.sh <domain to search>
```
## Main Features 
- Create a dated folder with recon notes
- Grab subdomains using assetfinder
- Probe for live hosts over ports 80/443
- Grab a screenshots of responsive hosts

### Requirements
- Download the Go version 1.10 or later.

If you have Go installed and configured (i.e. with `$GOPATH/bin` in your `$PATH`):

```
▶ go get -u github.com/tomnomnom/assetfinder
```
```
▶ go get -u github.com/tomnomnom/httprobe
```
```
▶ go get -u github.com/sensepost/gowitness
```


## Authors and Thanks
This script makes use of tools developped by the following people
- [Tomnomnom - assetfinder & httprobe](https://github.com/tomnomnom)
- [SensePost - gowitness](https://github.com/sensepost)

