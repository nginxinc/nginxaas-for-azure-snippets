# Demo

## What it's building

This is building two VNetsL main and peered. They are in different
regions but peered together. The concept here is similar to a hub and
spoke type architecture where you might have a main workload in a hub
and spokes out in different regions that help backhaul to it.

In the main vnet there are two VMs: wizard and wombat. These are a simulated workload (upstream).

in the peered vnet is where our actual N4A deployment will happen. It will have a public ip.

```
mainVnet    <-----------------> peeredVNet
  |                               |
 wizard|wombat                    n4a  - publicip


```

## Prereqs

* Recent `az` cli install
* bash
* Azure IAM -- these can be on the subscription or specific resource group
  * `Owner` -- necessary to grant permissions
  * `Key Vault Administrator` -- this allows the data actions on the keyvault (not directly granted by owner).


## Running it

1. `export group=my-unique-name`  -- we use this name for AZ DNS entries, so needs to be globally unique
2. `az group create -n $group --location eastus2` -- create a resource group for everything to go in
3. `az deployment group create --template-file main.bicep --resource-group=$group` run the initial deployment
4. `git checkout ssl`  -- switch branches
5. `git show` -- observe what's new
6. `./create-selfsigned.sh ${group}-akv ${group}-n4ademo.westcentralus.cloudapp.azure.com`
7. `az deployment group create --template-file main.bicep --resource-group=$group` update to include SSL Config
