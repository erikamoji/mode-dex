# MODE DEFI DEX - README

## Overview

MODE DEFI DEX is a highly sophisticated decentralized exchange platform optimized for Mode's Layer 2 scalability solution. It offers advanced trading functionalities, including margin trading, algorithmic trading strategies, and stop-loss orders. By integrating with Mode's Sequencer Fee Sharing (SFS), it incentivizes users and liquidity providers with a portion of the transaction fees. This document provides an extensive overview and guide to the smart contracts making up MODE DEFI DEX, detailing its architecture, functionalities, and usage.

## Smart Contracts

### Deployed Addresses:

- MarginTrading deployed to: 0xEC0357990512b3429eB89e119C0CF2B0c6f248cD
- AlgorithmicTrading deployed to: 0x8aeDA26FaC3DB234Aa9F1C29439Af5f551F8709A
- MyDex deployed to: 0x86351aABbc803B94623188b7e83413ee81f1dc3e
- OrderTypes deployed to: 0x7A68317754A34923784c1f202b14767d3c51ADd0
- MyDex registered with SFS at 0xBBd707815a7F7eb6897C7686274AFabd7B579Ff6
- Liquidity Pool set for MyDex at 0x0000000000000000000000000000000000000000

### 1. **AlgorithmicTrading.sol**

#### Description:
`AlgorithmicTrading.sol` implements automated trading strategies using price feeds from Chainlink. It leverages mathematical models to make trading decisions based on market price movements.

#### Key Components & Functionalities:
- **Price Storage**: Stores a limited number of price entries for strategy calculations.
- **SMA and RSI Calculations**: Implements functions to calculate the Simple Moving Average (SMA) and the Relative Strength Index (RSI), two critical indicators in trading strategies.
- **Automated Execution**: Uses Chainlink keepers for automated execution of trades based on algorithmic strategies.

#### Functions:
- **checkUpkeep**: Checks if the price needs updating based on the predefined interval, returning a boolean indicating if upkeep is needed.
- **performUpkeep**: Updates the latest price from the Chainlink Oracle and recalculates trading indicators if the upkeep condition is met.
- **updatePriceFromOracle**: Internal function to fetch and store the latest price from the Chainlink Oracle.
- **executeTradeStrategy**: Executes the trading strategy based on the calculated SMA and RSI indicators and current price.
- **calculateSMA**: Public view function to calculate the Simple Moving Average based on the last 'smaPeriod' prices.
- **calculateRSI**: Public view function to calculate the Relative Strength Index based on the last 'RSI_PERIOD' price changes.

### 2. **MarginTrading.sol**

#### Description:
`MarginTrading.sol` enables users to engage in leveraged trading. It manages user collateral and positions, ensuring secure and efficient handling of margin trades.

#### Key Components & Functionalities:
- **Collateral Management**: Allows users to deposit and withdraw collateral securely.
- **Position Management**: Users can open, close, and liquidate leveraged positions.
- **Risk Management**: Includes mechanisms to ensure positions are liquidated under certain conditions to manage the platform's risk.

#### Functions:
- **depositCollateral**: Allows users to deposit ETH as collateral for margin trading.
- **withdrawCollateral**: Allows users to withdraw their collateral, ensuring no open positions are present.
- **openPosition**: Opens a new margin trading position with specified leverage and entry price.
- **closePosition**: Closes an open margin trading position at the given exit price and calculates profit or loss.
- **liquidatePosition**: Liquidates an open position under certain conditions, typically when the position meets the margin call criteria.
- **calculateProfitLoss**: Private function to calculate profit or loss for a position based on the amount, leverage, entry price, and exit price.

### 3. **OrderTypes.sol**

#### Description:
`OrderTypes.sol` manages the lifecycle of various order types, including market, limit, and stop-loss orders. It ensures fair execution and maintains order integrity through commit-reveal schemes.

#### Key Components & Functionalities:
- **Commit-Reveal Mechanism**: Ensures order integrity and prevents front-running through a two-phase commit-reveal scheme.
- **Order Execution**: Checks and executes orders based on the current market price and the order conditions.
- **Order Management**: Tracks and manages the state of each order, including activation and cancellation.

#### Functions:
- **placeOrderCommit**: Allows users to place an order commitment with a hash representing the order details to prevent front-running.
- **revealOrder**: Reveals the order details after the commit phase is over, validating it with the original hash and signature.
- **checkAndExecuteOrders**: Checks all active orders to determine if they meet execution criteria based on the current price and order conditions, executing them accordingly.
- **executeOrder**: Internal function to execute an order by interacting with the DEX contract, marking it as inactive afterward.
- **isExecutable**: Internal pure function to check if an order meets the criteria for execution based on the current price.
- **getLatestPrice**: Public view function to fetch the latest price from the price feed.

### 4. **MyDex.sol**

#### Description:
`MyDex.sol` acts as the central hub for the decentralized exchange, interfacing with the individual trading components and the liquidity pool. It manages trade execution and integrates with the SFS contract.

#### Key Components & Functionalities:
- **SFS Integration**: Registers with the SFS contract to earn and distribute transaction fee shares.
- **Trade Execution**: Coordinates with the `MarginTrading`, `AlgorithmicTrading`, and `OrderTypes` contracts to execute trades.
- **Liquidity Pool Interaction**: Interfaces with a liquidity pool for trade execution, ensuring efficient market operations.

#### Functions:
- **registerWithSFS**: Registers the DEX with the Sequencer Fee Sharing contract to start earning a share of transaction fees.
- **setLiquidityPool**: Sets the address of the liquidity pool contract to be used for executing trades.
- **executeTrade**: Executes a trade on behalf of a user, interacting with the liquidity pool to swap assets at the current market price.

## Sequencer Fee Sharing (SFS) Integration

The DEX utilizes the Sequencer Fee Sharing (SFS) system to earn a portion of transaction fees. This section provides detailed information on how the integration works and benefits various stakeholders.

### Registration and Earning
1. **Registration Process**: The DEX contract calls the SFS contract's `register` function, passing its address as the recipient. This process assigns a unique SFS token ID to the DEX, representing its share of earned fees.
2. **Earning Fees**: As users perform trades on the DEX, a portion of the transaction fees is allocated to the DEX's SFS token ID.

### Fee Distribution
- **Distributing to Users**: The collected fees can be used to reward liquidity providers or reduce trading costs for users, creating a positive incentive loop and attracting more users to the platform.

## Development and Deployment

### Prerequisites
- Solidity Compiler: ^0.8.20.
- Node.js and NPM/Yarn: For managing project dependencies and scripts.
- Hardhat/Truffle: For compiling, testing, and deploying the contracts.

### Setup and Compilation
1. **Environment Setup**: Set up your development environment by cloning the repository and installing dependencies using npm or yarn.
2. **Configuration**: Configure the deployment scripts with the correct network settings and private keys (ensure not to expose private keys publicly).
3. **Compiling Contracts**: Compile the contracts using `npx hardhat compile` (or the respective command for your development environment).

### Deployment
1. **Network Selection**: Choose the appropriate Mode L2 testnet or mainnet for deployment.
2. **Executing Deployment**: Deploy the contracts using migration scripts or through an IDE like Remix, ensuring that the contracts are deployed in the correct order and configurations.

## Interacting with MODE DEFI DEX

Once deployed, users and developers can interact with the DEX through various means:

### For Traders
- **Contract Interaction**: Advanced users may interact directly with the smart contracts through web3 libraries or blockchain explorers that support contract interactions.

### For Developers
- **Smart Contract API**: Developers can build on top of the DEX by integrating with its smart contract functions, creating custom trading bots, or extending its functionalities.
- **Documentation and Examples**: Refer to detailed function documentation and example scripts for guidance on interacting with and extending the DEX.

## Conclusion

MODE DEFI DEX is a comprehensive solution for advanced decentralized trading, offering a rich set of features and robust integration with Mode's Layer 2 and SFS system. It's designed to cater to both casual traders and sophisticated financial users, promoting a more efficient, secure, and incentivized trading environment. Developers are encouraged to explore the contracts, contribute to the ecosystem, and build innovative trading solutions on top of MODE DEFI DEX. For more detailed information, consult the inline documentation and comments within each contract.