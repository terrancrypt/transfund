-include .env

fork-test:; forge test --fork-url https://polygon-mumbai.g.alchemy.com/v2/X5TDnhDZ4rXaZMJMggXrFQ-b5cySxi4O

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network polygon,$(ARGS)),--network polygon)
	NETWORK_ARGS := --rpc-url $(MUMBAI_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(POLYGONSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy-engine:
	@forge script script/DeployEngine.s.sol:DeployEngine $(NETWORK_ARGS)

deploy-mock-token:
	@forge script script/DeployMockToken.s.sol:DeployMockToken $(NETWORK_ARGS)

deploy-single-fund:
	@forge script script/DeploySingleFund.s.sol:DeploySingleFund $(NETWORK_ARGS)

