-include .env

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network polygon zkevm,$(ARGS)),--network polygon zkevm)
	NETWORK_ARGS := --rpc-url $(POLYGON_ZKEVM_TESTNET_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(POLYGONSCAN_ZKEVM_API_KEY) -vvvv
endif

deploy-uni:
	@forge script script/DeployMockUniswap.s.sol:DeployMockUniswap $(NETWORK_ARGS)
