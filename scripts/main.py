import time
from webbrowser import get
from scripts.global_helpful_script import fund_with_link, get_account, get_rarity,listen_for_event
from brownie import Vikings, network, config, VikingsGold
from web3 import Web3
from datetime import datetime

amount = Web3.toWei(0.01, "ether")
link_address = config["networks"][network.show_active()]["link_address"]

def deployErc20():
    account = get_account()
    print("deploying ... ")
    vikingsGold = VikingsGold.deploy({"from": account})


def deployErc721():
    account = get_account()  # get account
    # deploy the contract
    keyHash = config["networks"][network.show_active()]["key_hash"]
    vrf_coordinator = config["networks"][network.show_active()]["vrf_coordinator"]
    
    vikingsGold_contract = VikingsGold[-1]
    vikings_contract = Vikings.deploy(
        config["networks"][network.show_active()]["eth_usd_price_feed"],
        vikingsGold_contract.address,
        keyHash,
        vrf_coordinator,
        link_address,
        {"from": account}
    )
 





def fundContractWithVGD():
    print("Funding the contract with VGD")
    account = get_account()
    vikingsGold_contract = VikingsGold[-1]
    vikings_contract = Vikings[-1]
    totalBalance = vikingsGold_contract.balanceOf(account.address)
    vikingsGold_contract.transfer(vikings_contract.address, totalBalance,{"from":account})

    print("Funded")


def claim():
    account = get_account()
    vikingsGold_contract = VikingsGold[-1]
    vikings_contract = Vikings[-1]
    print("Claiming ...")
    if vikings_contract.playerBalance(account.address) == 0:
        print("You don't have funds or you're not a player")
    else:
        claim = vikings_contract.claim({"from": account})
        claim.wait(1)
        balanceClaimed = claim.events["claimed"]["balance"]
        print(f"You've just claimed {balanceClaimed}")
        print(
            f"you have now {Web3.fromWei(vikingsGold_contract.balanceOf(account.address),'ether')} Vikings Gold"
        )


def claim5days():
    account = get_account()
    vikingsGold_contract = VikingsGold[-1]
    vikings_contract = Vikings[-1]
    lastClaim = vikings_contract.lastClaim(account.address)
    nextClaiminSeconds = lastClaim + 432000
    nextClaim = datetime.fromtimestamp(nextClaiminSeconds).strftime("%B,%d,%I:%M:%S")
    print("Claiming ...")
    if vikings_contract.isPlayerCanClaim(account.address) == False:
        print("your can't claim unitl ", nextClaim)
    else:
        if vikings_contract.playerBalance(account.address) == 0:
            print("You don't have funds or you're not a player")
        else:
            claim = vikings_contract.claim5days({"from": account})
            claim.wait(1)
            balanceClaimed = claim.events["claimed"]["balance"]
            print(f"You've just claimed {balanceClaimed}")
            print(
                f"you have now {Web3.fromWei(vikingsGold_contract.balanceOf(account.address),'ether')} Vikings Gold"
            )


def openMysteryVikingBox():
    print("OPENING THE BOX ....")
    account = get_account()
    vikings_contract = Vikings[-1]
    common, epic, legend = vikings_contract.entryFee()
    print(f"You will spend {common} to open The Box")
    buyBox = vikings_contract.openMysteryVikingBox(
        {"from": account, "value": common + 100001}
    )
    
    listen_for_event(vikings_contract,"newVikingBorn")
    
    requestid = buyBox.events["requestToCreatNewViking"]["requestId"]
    id = vikings_contract.vikingIdOfRequestId(requestid)
    rarity = vikings_contract.vikingRarity(id)
    print(f"Your Viking Id is : {id} and it's {get_rarity(rarity)}")
  


def openEpicVikingBox():
    print("OPENING THE BOX ....")
    account = get_account()
    vikings_contract = Vikings[-1]
    common, epic, legend = vikings_contract.entryFee()
    print(f"You will spend {epic} to open The Box")
    buyBox = vikings_contract.openEpicVikingBox(
        {"from": account, "value": epic + 100001}
    )
    listen_for_event(vikings_contract,"newVikingBorn")
    
    requestid = buyBox.events["requestToCreatNewViking"]["requestId"]
    id = vikings_contract.vikingIdOfRequestId(requestid)
    rarity = vikings_contract.vikingRarity(id)
    print(f"Your Viking Id is : {id} and it's {get_rarity(rarity)}")


def openLegendaryVikingBox():
    print("OPENING THE BOX ....")
    account = get_account()
    vikings_contract = Vikings[-1]
    common, epic, legend = vikings_contract.entryFee()
    print(f"You will spend {legend} to open The Box")
    buyBox = vikings_contract.openLegendaryVikingBox(
        {"from": account, "value": legend + 100001}
    )
    listen_for_event(vikings_contract,"newVikingBorn")
    
    requestid = buyBox.events["requestToCreatNewViking"]["requestId"]
    id = vikings_contract.vikingIdOfRequestId(requestid)
    rarity = vikings_contract.vikingRarity(id)
    print(f"Your Viking Id is : {id} and it's {get_rarity(rarity)}")


def fight():
    vikings_contract = Vikings[-1]
    account = get_account()
    vikingId = 1
    lastFight = vikings_contract.lastFight(vikingId)
    nextFightinSeconds = lastFight + 86400
    nextFight = datetime.fromtimestamp(nextFightinSeconds).strftime("%B,%d,%I:%M:%S")
    if vikings_contract.isVikingExist(vikingId) == False:
        print("Viking doesn't exist")
    else:
        if vikings_contract.ownerOf(vikingId) != account.address:
            print("this is not your fighter")
        else:
            if vikings_contract.isVikingCanFight(vikingId) == False:
                print("your fighter can't fight unitl ", nextFight)

            else:
                print("You will join the battle ...")
                fightTx = vikings_contract.fight(vikingId, {"from": account})
                fightTx.wait(vikingId)
                id = fightTx.events["fightFinished"]["id"]
                gain = fightTx.events["fightFinished"]["gain"]
                print(
                    f"The viking number {id} is Won and gain for his Owner {gain} dollars"
                )

def mainFunc():
    
    nft_contract = Vikings[-1]
    account =get_account()
    #fund_with_link(nft_contract.address,link_address,account)
    # getLinkBack = nft_contract.getLinkBack({"from":account}) # onlyowner
    # getLinkBack.wait(1)
    # getEthBack = nft_contract.getEth({"from":account})#onlyOwner
    # getEthBack.wait(1)
    # openMysteryVikingBox()
    openLegendaryVikingBox()
    openEpicVikingBox()
    #fundContractWithVGD()
    #claim()
    #fight()


    
def main():
    # deployErc20()
    #deployErc721()
    mainFunc()
