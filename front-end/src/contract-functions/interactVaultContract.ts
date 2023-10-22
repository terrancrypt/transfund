import { writeContract, readContract } from "@wagmi/core";
import VaultABI from "../abis/FundVaultABI.json";
import { formatEther, parseEther } from "viem";

// Read
async function getAsset(
  chainId: number,
  vaultContract: string
): Promise<string | null> {
  try {
    const result = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "asset",
      chainId,
    });
    return String(result);
  } catch (error) {
    return null;
  }
}

async function getTotalCapital(
  chainId: number,
  vaultContract: string
): Promise<string | null> {
  try {
    const result: any = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "getTotalCapitalInVault",
      chainId,
    });
    return formatEther(result);
  } catch (error) {
    return null;
  }
}

async function getTotalSharesCanMint(chainId: number, vaultContract: string) {
  try {
    const result = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "s_totalSharesCanMint",
      chainId,
    });
    return result;
  } catch (error) {
    return null;
  }
}

async function getVaultOwner(
  chainId: number,
  vaultContract: string
): Promise<string | null> {
  try {
    const result = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "i_vaultOwner",
      chainId,
    });
    return String(result);
  } catch (error) {
    return null;
  }
}

async function getOwnerSharesPercent(
  chainId: number,
  vaultContract: string
): Promise<string | null> {
  try {
    const result = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "i_ownerSharesPercentage",
      chainId,
    });
    return String(result);
  } catch (error) {
    return null;
  }
}

async function getAmountSharesCanMint(
  chainId: number,
  vaultContract: string
): Promise<string | null> {
  try {
    const result: any = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "s_totalSharesCanMint",
      chainId,
    });
    return formatEther(result);
  } catch (error) {
    return null;
  }
}

async function getTotalSharesSupply(
  chainId: number,
  vaultContract: string
): Promise<string | null> {
  try {
    const result: any = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "totalSupply",
      chainId,
    });
    return formatEther(result);
  } catch (error) {
    return null;
  }
}

async function getAmountAssetToWithdraw(
  chainId: number,
  vaultContract: string,
  amountShares: any
): Promise<string | null> {
  try {
    console.log(amountShares);
    const result: any = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "getAmountAssetToWithdraw",
      args: [amountShares],
      chainId,
    });
    return formatEther(result);
  } catch (error) {
    return null;
  }
}

async function getFee(
  chainId: number,
  vaultContract: string
): Promise<string | null> {
  try {
    const result = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "s_entryFeeBasicPoints",
      chainId,
    });
    return String(result);
  } catch (error) {
    return null;
  }
}

async function getDivideProfits(
  chainId: number,
  vaultContract: string
): Promise<string | null> {
  try {
    const result = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "i_divideProfits",
      chainId,
    });
    return String(result);
  } catch (error) {
    return null;
  }
}

async function getSharesBalanceOf(
  chainId: number,
  vaultContract: string,
  user: string
): Promise<string | null> {
  try {
    const result: any = await readContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "balanceOf",
      args: [user],
      chainId,
    });
    return formatEther(result);
  } catch (error) {
    console.log(error);
    return null;
  }
}

// write
async function addInvestToken(
  chainId: number,
  vaultContract: string,
  token: string,
  priceFeed: string
) {
  try {
    const { hash } = await writeContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "addInvestToken",
      args: [token, priceFeed],
      chainId,
    });
    return hash;
  } catch (error) {
    return null;
  }
}

async function depositToVault(
  chainId: number,
  vaultContract: string,
  amount: number,
  user: string
) {
  try {
    const { hash } = await writeContract({
      address: vaultContract as any,
      abi: VaultABI,
      functionName: "deposit",
      args: [parseEther(String(amount)), user],
      chainId,
    });
    return hash;
  } catch (error) {
    return null;
  }
}

export {
  getAsset,
  getTotalCapital,
  getTotalSharesCanMint,
  getVaultOwner,
  addInvestToken,
  getOwnerSharesPercent,
  getFee,
  getDivideProfits,
  getAmountSharesCanMint,
  getTotalSharesSupply,
  getSharesBalanceOf,
  depositToVault,
  getAmountAssetToWithdraw,
};
