# Project Description
We introduced a possibility to execute a Flash Loan Attack (FLA) on the UZHETH network and point out prevention methods. Our FLA is an oracle manipulation attack and exploits a collateralized loan provider (CLP) by first borrowing token A as flash loan which then will be swapped partly to token B on a decentralized exchange (DEX) and finally making profit by borrowing a loan of token A against token B from the CLP which calculates lending amounts according to the manipulated liquidity pool reserves. As prevention techniques, we suggest CLPs to use averaged token prices for lending amount calculations, respectively the introduction of price oracles, e.g. Chainlink. For more information check out our [report](report.pdf). 

## Members of Group 033:
- [Pascal Emmenegger](https://github.com/pemmenegger)
- [Nicola Crimi]()
- [Maximilian Kiefer]()