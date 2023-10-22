interface Contract {
  [chainId: number]: {
    address: string;
  };
}

const engineContract: Contract = {
  // ETH Sepolia
  11155111: {
    address: "0xc401Ee4eF9bDe268F711C0Dc6DD9B1fAE6Cc92ba",
  },
  // Polygon Mumbai
  80001: {
    address: "0xB9019c710C8620cf23531c6C92676d0bcCDB2306",
  },
};

const mockWETHContract: Contract = {
  // ETH Sepolia
  11155111: {
    address: "0x0CE0820B1B5e05b0E4e60Fe5475D84032A2dF621",
  },
  // Polygon Mumbai
  80001: {
    address: "0xefa6a3927158865068105AEbcB71fD1c9aF2913f",
  },
};

const mockWBTCContract: Contract = {
  // ETH Sepolia
  11155111: {
    address: "0xaA51c145Ef72411f9795c35DC96AD1adffBf239a",
  },
  // Polygon Mumbai
  80001: {
    address: "0x2DAC1213D429c3ab41500D2B5a7409C274BcDB63",
  },
};

const mockUSDCContract: Contract = {
  // ETH Sepolia
  11155111: {
    address: "0xb0608A07150e675435173A5eCae2FBC797eD22CC",
  },
  // Polygon Mumbai
  80001: {
    address: "0x7DFdCaE1e6a90be0b3CD10e949cE30b137Da58f4",
  },
};

const mockDAIContract: Contract = {
  // ETH Sepolia
  11155111: {
    address: "0xf42b3262E1F0B706Daac8b166a9c295C393f9Ab8",
  },
  // Polygon Mumbai
  80001: {
    address: "0x641b565115615C242414db413013b906D59bf9b2",
  },
};

export {
  engineContract,
  mockWETHContract,
  mockWBTCContract,
  mockUSDCContract,
  mockDAIContract,
};
