# Central Private DNS

This repository is the source of truth for shared networking and private DNS values used by application teams.

## Ownership
- Network team owns the private DNS zone lifecycle.
- Application teams consume approved values, they do not create their own private DNS zones unless explicitly approved.

## Generated output contract
The network repo creates the shared private DNS zones and then writes generated JSON artifacts for each environment.

There are separate files for each purpose:
- `generated/<environment>/approved-network-values.json` for approved private DNS zone IDs
- `generated/<environment>/approved-vnet-links.json` for approved VNet links

## Usage
Application repos should read the relevant generated environment file for the concern they need and pass those values into the shared private endpoint modules.

## Supported shared values
- approved private DNS zone IDs for Azure services
- approved VNet links
- generated timestamp and ownership metadata
