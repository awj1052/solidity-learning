npm init -y  
npm install --save-dev hardhat  
npx hardhat init  
    -> Create a TypeScript project  
    -> root, y, y

(test)  
npx hardhat test  

(Plugins)
npm install --save-dev @nomiclabs/hardhat-vyper
- VS Code Extension: vyper

npx hardhat compile
npx hardhat typechain
npx hardhat test test\MyToken.ts

npx hardhat node
npx hardhat ignition deploy ignition\modules\deploy.ts --network localhost
npx hardhat ignition deploy ignition\modules\deploy.ts --network kairos

npx hardhat verify --network kairos 0xB9AbD638A44bFF4216a8e7f6CaAb9EFc44e809A4 "MyToken" "MT" 18 100
npx hardhat verify --network kairos 0xB92044485dD0B0840051689027872B1e7765bfde 
