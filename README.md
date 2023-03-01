

# Small Description :

        I made this P2E game to improve my Solidity knowledge.
        This small game, it works with an interactive ROI system 
        depends on your chance and rarity box, you will get a viking. Then you can join battles.
        # You can only join the battle if you hold a viking NFT.
        # You can join the battle only 1 time per 24h.
        # You will get a $VGD as reward.
        # Reward depends on your Viking rarity (see table below).
    
          * Common BOX 250 Dollars *

        | Rarity        | Chance        | 
        | ------------- |:-------------:|
        | Common        | 60 %          | 
        | Rare          | 20 %          | 
        | SuperRare     | 10 %          | 
        | Epic          | 6  %          | 
        | Legend        | 3  %          |   
        | Super Legend  | 1  %          |   

          * Epic Box 400 dollars *

        | Rarity        | Chance        |  
        | ------------- |:-------------:|
        | Common        | 36 %          | 
        | Rare          | 25 %          | 
        | SuperRare     | 20 %          | 
        | Epic          | 15  %         | 
        | Legend        | 3  %          |   
        | Super Legend  | 1  %          | 

          * Legend Box 750 dollar * (no Common ;)

        | Rarity        | Chance        | 
        | ------------- |:-------------:|
        | Rare          | 18 %          | 
        | SuperRare     | 40 %          | 
        | Epic          | 30  %         | 
        | Legend        | 8  %          |   
        | Super Legend  | 4  %          |


        ---------- Rewards -------------

        | Rarity        | Gain          |
        | ------------- |:-------------:|
        | Common        | $6            | 
        | Rare          | $8            | 
        | SuperRare     | $10           | 
        | Epic          | $12           | 
        | Legend        | $25           |   
        | Super Legend  | $35           | 


        ------ Claim -----

        Well! For a lot of reasons. The claim should be from 10 days to 10 days or plus to avoid price bearish. But it's just a test for players, I'll make it accessible anytime.

        As reward, the contract will give you VGD depends on actually price, but for now it will give 1 VGD for 1 dollar.
        Example : you have an epic viking after fight you can claim 12.5 VGD


        ------- BIG NOTICE -----

        Even if you are a tester not a developer, you still need to interact with python until I create a simple website in the next few days. But I'll try to make it simple, you need just to follow instructions.


# for Developers : 

      - there's 2 claim methods 
        claim() ==> player can withdraw anytime
        claim5days() ==> player can withdraw 5 to 5 days 
        or you can make it more, replace 5 days with number of seconds/hours/days
  
      - I tested all functionality on the rinkeby network
      - Opening the box can take up to 200 s you can change it but be careful on time of 
        Chainlink node response

# Help ? :

    `Discord` : Mowgli#7713


# Next Updates :

    - A small website ^^'
    - add URIs
    - possibilty to add a taxe in the claim before a date

      




