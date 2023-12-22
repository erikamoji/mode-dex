# MODE DEFI DEX - README

## Overview

MODE DEFI DEX is a decentralized exchange platform optimized for Mode's Layer 2 blockchain, designed to provide advanced trading functionalities such as margin trading, algorithmic trading strategies, and stop-loss orders. The exchange integrates with Mode's Sequencer Fee Sharing (SFS) mechanism, allowing it to earn a portion of transaction fees, which can be distributed as additional incentives to users or liquidity providers. This documentation provides an overview of the MODE DEFI DEX smart contracts and their functionalities.

## Smart Contracts

### 1. **AlgorithmicTrading.sol**

#### Description:
This contract is designed for algorithmic trading strategies using Chainlink price feeds. It includes functionalities to update prices, calculate Simple Moving Average (SMA), and Relative Strength Index (RSI) for trading strategy implementation.

#### Key Functions:
- `checkUpkeep`: Checks if it's time to update the price feed based on a predefined interval.
- `performUpkeep`: Updates the price from the Chainlink Oracle when triggered by the keeper.
- `executeTradeStrategy`: Executes the trading strategy based on SMA and RSI indicators.

### 2. **MarginTrading.sol**

#### Description:
This contract enables margin trading functionality, allowing users to open and close leveraged positions, deposit and withdraw collateral, and manage liquidations.

#### Key Functions:
- `depositCollateral`: Allows users to deposit collateral for margin trading.
- `withdrawCollateral`: Permits withdrawal of collateral, ensuring no open positions.
- `openPosition`: Users can open a leveraged trading position.
- `closePosition`: Users can close their open trading positions.
- `liquidatePosition`: Allows liquidators to close positions that meet certain conditions.

### 3. **OrderTypes.sol**

#### Description:
Manages different order types for the decentralized exchange, including market orders, limit orders, and stop-loss orders. It also includes a mechanism for order commitments to ensure fair order execution.

#### Key Functions:
- `placeOrderCommit`: Commits an order to the exchange, waiting for the reveal phase.
- `revealOrder`: Reveals the order details after a certain number of blocks.
- `checkAndExecuteOrders`: Checks active orders against current market conditions and executes them if criteria are met.

### 4. **MyDex.sol**

#### Description:
Acts as the main entry point for the decentralized exchange, integrating margin trading, algorithmic trading, and different order types. It's responsible for handling trade execution and interacting with the liquidity pool.

#### Key Functions:
- `registerWithSFS`: Registers the DEX with the Sequencer Fee Sharing (SFS) contract to earn a portion of the transaction fees.
- `setLiquidityPool`: Sets the liquidity pool address for trade execution.
- `executeTrade`: Executes trades on behalf of users, interacting with the liquidity pool.

## Sequencer Fee Sharing (SFS) Integration

The MODE DEFI DEX integrates with Mode's Sequencer Fee Sharing mechanism through the following approach:

1. **Registration**: The DEX registers itself with the SFS contract to start earning a portion of the transaction fees.
2. **Token ID Management**: Upon registration, the DEX is assigned an SFS token ID, which tracks the fees earned by the DEX.
3. **Fee Distribution**: Earned fees can be distributed to users or liquidity providers as additional incentives.

## Setup and Compilation

### Prerequisites:

- Node.js and npm installed.
- Solidity ^0.8.20 compiler.
- Access to Mode's L2 testnet or mainnet for deployment.

### Instructions:

1. **Clone Repository**: Clone the MODE DEFI DEX repository to your local machine.
2. **Install Dependencies**: Navigate to the project directory and install necessary dependencies:

   ```
   npm install
   ```

3. **Compile Contracts**: Compile the smart contracts using Hardhat or a similar framework:

   ```
   npx hardhat compile
   ```

4. **Deploy Contracts**: Deploy the contracts to Mode's L2 using your preferred method (e.g., Hardhat scripts, Remix, or Truffle).

## Interacting with the DEX

Once deployed, you can interact with the DEX through smart contract calls or a frontend interface if available. Ensure to handle user permissions, collateral management, and order execution according to the DEX's features and your trading strategy.

## Conclusion

MODE DEFI DEX represents a comprehensive solution for advanced trading on Mode's Layer 2 blockchain. With its SFS integration and a suite of trading functionalities, it is poised to offer a robust and user-friendly experience for traders and liquidity providers alike. For detailed function descriptions, parameter information, and more, refer to the inline documentation within each contract.