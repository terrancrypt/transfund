import getBlockExplorerUrl from "@/utils/getBlockExplorerUrl";
import shortenAddress from "@/utils/shortenAddress";
import { useParams } from "next/navigation";
import { useAccount, useNetwork } from "wagmi";
import { Button, Form, Modal, Statistic, Input, message, Spin } from "antd";
import { InputNumber } from "antd";
import { useEffect, useState } from "react";
import {
  depositToVault,
  getAmountAssetToWithdraw,
  getAmountSharesCanMint,
  getAsset,
  getDivideProfits,
  getFee,
  getOwnerSharesPercent,
  getSharesBalanceOf,
  getTotalCapital,
  getTotalSharesSupply,
  getVaultOwner,
} from "@/contract-functions/interactVaultContract";
import {
  approveContract,
  fetchTokenBalance,
  getTokenSymbol,
} from "@/contract-functions/interactTokenContract";
import { useRouter } from "next/router";
import { waitForTransaction } from "wagmi/actions";
import { parseEther } from "viem";

interface VaultData {
  owner: string | null;
  assetAddress: string | null | undefined;
  assetSymbol: string | null | undefined;
  ownerSharesPercent: string | null;
  fee: string | null;
  divideProfits: string | null;
  totalValue: string | null;
  totalSharesMinted: string | null;
  amountSharesCanMint: string | null;
  userBalance: string | null;
}

const SingleVaultPage = () => {
  const [messageApi, contextHolder] = message.useMessage();
  const [form] = Form.useForm();
  const { chain } = useNetwork();
  const {
    query: { address },
  } = useRouter();
  const { address: user } = useAccount();
  const [txLoading, setTxLoading] = useState<boolean>(false);
  const [vaultData, setVaultData] = useState<VaultData>();
  const [isLoading, setIsLoading] = useState<boolean>(false);

  const fetchVaultData = async () => {
    try {
      setIsLoading(true);
      if (chain) {
        const owner = await getVaultOwner(
          chain.id as number,
          address as string
        );

        const asset = await getAsset(chain.id, address as string);
        let assetSymbol;
        if (asset != null) assetSymbol = await getTokenSymbol(chain.id, asset);
        const ownerSPercent = await getOwnerSharesPercent(
          chain.id,
          address as string
        );
        const fee = await getFee(chain.id, address as string);
        const divideProfits = await getDivideProfits(
          chain.id,
          address as string
        );
        const totalCapital = await getTotalCapital(chain.id, address as string);
        const amountSharesCanMint = await getAmountSharesCanMint(
          chain.id,
          address as string
        );
        const sharesMinted = await getTotalSharesSupply(
          chain.id,
          address as string
        );
        const userBalance = await getSharesBalanceOf(
          chain.id,
          address as string,
          user as string
        );

        setVaultData({
          owner,
          assetAddress: asset,
          assetSymbol,
          ownerSharesPercent: ownerSPercent,
          fee,
          divideProfits,
          totalValue: parseFloat(totalCapital as string).toLocaleString(),
          amountSharesCanMint: parseFloat(
            amountSharesCanMint as string
          ).toLocaleString(),
          totalSharesMinted: parseFloat(
            sharesMinted as string
          ).toLocaleString(),
          userBalance: parseFloat(userBalance as string).toLocaleString(),
        });
      }
    } catch (error) {
      message.error("Fetch vault data failed!");
    } finally {
      setIsLoading(false);
    }
  };

  const onFinish = async (values: any) => {
    const amount = Number(values.amount);
    console.log(amount);
    if (amount <= 0 || amount == undefined) message.error("Invalid Amount!");
    try {
      const chainId = chain?.id;
      setTxLoading(true);
      messageApi.open({
        type: "loading",
        content: "Transaction in progress...",
        duration: 0,
      });
      // Aprrove
      const hash = await approveContract(
        chainId as any,
        vaultData?.assetAddress as any,
        user as any,
        amount,
        address as any
      );
      if (hash) {
        const wait = await waitForTransaction({
          chainId,
          hash,
        });
        if (wait) {
          message.success("Approve success!");
          // Deposit
          const result = await depositToVault(
            chainId as any,
            address as any,
            amount,
            user as any
          );
          if (result) {
            const waitSecond = await waitForTransaction({
              chainId,
              hash: result,
            });
            if (waitSecond) {
              message.success("Deposited!").then(() => messageApi.destroy());
            }
          }
        }
      }
    } catch (error) {
      message.error("Transaction failed!");
    } finally {
      setTxLoading(false);
    }
  };

  useEffect(() => {
    fetchVaultData();
  }, [address]);

  return (
    <>
      {contextHolder}
      <Spin spinning={isLoading}>
        <div className="container px-28">
          <div className="text-2xl font-bold flex items-center gap-2">
            VAULT: {shortenAddress(address as string)}
            <a
              href={getBlockExplorerUrl(chain ? chain.id : "") + address}
              target="_blank"
              rel="noopener noreferrer"
            >
              <span>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  strokeWidth={1.5}
                  stroke="currentColor"
                  className="w-6 h-6"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25"
                  />
                </svg>
              </span>
            </a>
          </div>
          <div className="mt-3 flex justify-between">
            <div className="space-y-3 text-sm">
              <p>
                Owner:{" "}
                <a
                  href={getBlockExplorerUrl(chain ? chain.id : "") + address}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="hover:underline transition-all"
                >
                  {shortenAddress(vaultData?.owner)}
                </a>
              </p>
              <p>Asset to deposit: {vaultData?.assetSymbol}</p>
              <p>Owner's shares percentage: {vaultData?.ownerSharesPercent}%</p>
              <p>Deposit fee: {Number(vaultData?.fee) / 100}%</p>
              <p>Divide profits: {vaultData?.divideProfits}%</p>
            </div>
            <div className="flex gap-8">
              <div className="space-y-4">
                <Statistic
                  title="Total USD Value"
                  value={("$" + vaultData?.totalValue) as any}
                />
                <Statistic
                  title="Amount Shares Minted"
                  value={(vaultData?.totalSharesMinted as any) + " vTFT"}
                />
              </div>
              <div className="space-y-4">
                <Statistic
                  title="Available Shares To Mint"
                  value={(vaultData?.amountSharesCanMint as any) + " vTFT"}
                />
                <Statistic
                  title="Your Shares In Vault"
                  value={(vaultData?.userBalance as any) + " vTFT"}
                />
              </div>
            </div>
            <div className="pt-4 px-4 rounded-lg border">
              <Form
                layout="vertical"
                form={form}
                style={{ maxWidth: "inline" === "inline" ? "none" : 600 }}
                onFinish={onFinish}
              >
                <Form.Item label="Deposit" name="amount">
                  <Input placeholder="amount" />
                </Form.Item>
                <Form.Item>
                  <button className="rounded-lg py-1 px-2 bg-black text-white">
                    transaction
                  </button>
                </Form.Item>
              </Form>
            </div>
          </div>
        </div>
      </Spin>
    </>
  );
};

export default SingleVaultPage;
