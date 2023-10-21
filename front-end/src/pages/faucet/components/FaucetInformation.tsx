import React from "react";

interface FaucetInforProps {
  chainName: string;
}

const FaucetInformation: React.FC<FaucetInforProps> = ({ chainName }) => {
  const renderSymbol = () => {
    if (chainName == "Polygon Mumbai") {
      return "MATIC";
    } else {
      return "ETH";
    }
  };

  const renderFaucetURL = () => {
    if (chainName == "Sepolia") {
      return (
        <a
          href="https://sepoliafaucet.com/"
          target="_blank"
          className="underline"
        >
          Sepolia Faucet
        </a>
      );
    } else if (chainName == "Polygon Mumbai") {
      return (
        <a
          href="https://faucet.polygon.technology/"
          target="_blank"
          className="underline"
        >
          Polygon Mumbai Faucet
        </a>
      );
    }
  };

  return (
    <div className="px-6 py-4 shadow-md flex-1 bg-white rounded-lg">
      <div className="flex items-center justify-between text-gray-700">
        <div className="text-lg font-bold">Information</div>
        <div className="flex items-center space-x-2">
          <div className="text-sm text-gray-500">Current Network:</div>
          <div className="text-sm font-bold text-gray-700">{chainName}</div>
        </div>
      </div>
      <div className="mt-4">
        <div className="text-sm text-gray-500">
          With testnet Faucet you can get free assets to test the protocol. Make
          sure to switch your wallet provider to the {chainName} network, select
          desired asset, and click ‘Faucet’ to get tokens transferred to your
          wallet.
        </div>
        <br />
        <div className="text-sm text-gray-500">
          You need {chainName} {renderSymbol()} to pay transaction fees in the
          protocol. Pick up at {renderFaucetURL()}.
        </div>
      </div>
    </div>
  );
};

export default FaucetInformation;
