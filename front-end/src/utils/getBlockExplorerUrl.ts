const getBlockExplorerUrl = (chainId: number | string) => {
  if (chainId == 80001) {
    return "https://mumbai.polygonscan.com/address/";
  } else {
    return "https://sepolia.etherscan.io/address/";
  }
};

export default getBlockExplorerUrl;
