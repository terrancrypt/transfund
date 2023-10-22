import React, { useEffect, useState } from "react";
import { Spin, message } from "antd";
import { getAllContractAddresses } from "@/contract-functions/interactEngineContract";
import {
  addInvestToken,
  getAsset,
  getTotalCapital,
  getVaultOwner,
} from "@/contract-functions/interactVaultContract";
import { getTokenSymbol } from "@/contract-functions/interactTokenContract";
import Link from "next/link";
import shortenAddress from "@/utils/shortenAddress";
import getBlockExplorerUrl from "@/utils/getBlockExplorerUrl";

interface TableVaultProps {
  chainId: number;
}

interface Vault {
  address: string;
  assetSymbol: string | null | undefined;
  totalValue: string | null;
  owner: string | null;
}

const TableVault: React.FC<TableVaultProps> = ({ chainId }) => {
  const [vault, setVault] = useState<Vault[]>();
  const [isLoading, setIsLoading] = useState<boolean>(false);

  const fetchVaultAdresses = async () => {
    try {
      setIsLoading(true);
      let vaultData: Vault[] = [];
      const addresses = await getAllContractAddresses(chainId);
      console.log("Addresses", addresses);

      if (addresses != null) {
        for (let i = 0; i < addresses.length; i++) {
          const address = addresses[i];
          const asset = await getAsset(chainId, address);
          let assetSymbol;
          if (asset != null) assetSymbol = await getTokenSymbol(chainId, asset);
          const owner = await getVaultOwner(chainId, address);

          const totalCapital = await getTotalCapital(chainId, address);

          vaultData.push({
            address,
            assetSymbol,
            totalValue: parseFloat(totalCapital as string).toLocaleString(),
            owner,
          });
        }
        setVault(vaultData);
      }
    } catch (error) {
      message.error("Can't fetch data!");
      return null;
    } finally {
      setIsLoading(false);
    }
  };

  // // ========
  // const addETH = (contract: string) => {
  //   let eth;
  //   let ethPriceFeed;
  //   if (chainId == 80001) {
  //     eth = "0xefa6a3927158865068105AEbcB71fD1c9aF2913f";
  //     ethPriceFeed = "0x0715A7794a1dc8e42615F059dD6e406A6594651A";
  //   } else {
  //     eth = "0x0CE0820B1B5e05b0E4e60Fe5475D84032A2dF621";
  //     ethPriceFeed = "0x694AA1769357215DE4FAC081bf1f309aDC325306";
  //   }
  //   console.log(chainId, contract, eth, ethPriceFeed);
  //   addInvestToken(chainId, contract, eth, ethPriceFeed);
  // };

  // const addBTC = (contract: string) => {
  //   let btc;
  //   let btcPriceFeed;
  //   if (chainId == 80001) {
  //     btc = "0x2DAC1213D429c3ab41500D2B5a7409C274BcDB63";
  //     btcPriceFeed = "0x007A22900a3B98143368Bd5906f8E17e9867581b";
  //   } else {
  //     btc = "0xaA51c145Ef72411f9795c35DC96AD1adffBf239a";
  //     btcPriceFeed = "0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43";
  //   }
  //   console.log(chainId, contract, btc, btcPriceFeed);
  //   addInvestToken(chainId, contract, btc, btcPriceFeed);
  // };
  // // ========

  const renderVault = (): any => {
    try {
      if (vault?.length != 0 && vault != undefined) {
        return vault.map((item, index) => (
          <tr key={index} className="bg-white border-b">
            <th
              scope="row"
              className="px-6 py-4 whitespace-nowrap hover:underline transition-all"
            >
              <Link href={`/vaults/${item.address}`}>
                {shortenAddress(item.address)}
              </Link>
            </th>
            <td className="px-6 py-4">{item.assetSymbol}</td>
            <td className="px-6 py-4">
              <a
                href={getBlockExplorerUrl(chainId) + item.owner}
                target="_blank"
                rel="noopener noreferrer"
                className="hover:underline transition-all"
              >
                {shortenAddress(item.owner)}
              </a>
            </td>
            <td className="px-6 py-4">${item.totalValue}</td>
            <td className="px-6 py-4 space-x-4">
              <button className="rounded-lg py-1 px-2 border hover:bg-gray-300 hover:scale-110 transition-all">
                <Link href={`/vaults/${item.address}`}>See more</Link>
              </button>
            </td>
          </tr>
        ));
      }
    } catch (error) {
      message.error("Can't render vault");
    }
  };

  useEffect(() => {
    fetchVaultAdresses();
  }, []);

  return (
    <>
      <Spin spinning={isLoading}>
        <div className="relative overflow-x-auto shadow-md flex-1 bg-white rounded-lg">
          <table className="min-w-full divide-y divide-gray-200 text-center">
            <thead className="text-xs text-gray-700 uppercase bg-gray-50">
              <tr>
                <th scope="col" className="px-6 py-3">
                  Vault
                </th>
                <th scope="col" className="px-6 py-3">
                  Asset
                </th>
                <th scope="col" className="px-6 py-3">
                  Owner
                </th>
                <th scope="col" className="px-6 py-3">
                  Total Value
                </th>
                <th scope="col" className="px-6 py-3"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 text-sm">
              {renderVault()}
            </tbody>
          </table>
        </div>
      </Spin>
    </>
  );
};

export default TableVault;
