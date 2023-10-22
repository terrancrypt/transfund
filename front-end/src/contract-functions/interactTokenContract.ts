import { readContract } from "@wagmi/core";
import MockTokenABI from "../abis/MockTokenABI.json";
import { writeContract, fetchBalance } from "@wagmi/core";
import { formatEther, parseEther } from "viem";

// read
async function getTokenSymbol(
  chainId: number,
  address: string
): Promise<string | null> {
  try {
    const result = await readContract({
      address: address as any,
      abi: MockTokenABI,
      chainId,
      functionName: "symbol",
    });
    return String(result);
  } catch (error) {
    return null;
  }
}

async function fetchTokenBalance(
  chainId: number,
  tokenAddress: string,
  userAddress: string
): Promise<any | null> {
  try {
    const result = await fetchBalance({
      address: userAddress as any,
      token: tokenAddress as any,
      chainId,
      formatUnits: "ether",
    });
    return formatEther(result.value);
  } catch (error) {
    return null;
  }
}

// write
async function writeFaucet(
  chainId: number,
  address: string,
  userAccount: string
): Promise<string | null> {
  try {
    const { hash } = await writeContract({
      address: address as any,
      abi: MockTokenABI,
      chainId,
      functionName: "faucet",
      account: userAccount as any,
    });
    return hash;
  } catch (error) {
    return null;
  }
}

async function approveContract(
  chainId: number,
  address: string,
  userAccount: string,
  amount: number,
  spender: string
) {
  try {
    const { hash } = await writeContract({
      address: address as any,
      abi: MockTokenABI,
      chainId,
      functionName: "approve",
      args: [spender, parseEther(String(amount))],
      account: userAccount as any,
    });
    return hash;
  } catch (error) {
    return null;
  }
}

export { getTokenSymbol, writeFaucet, fetchTokenBalance, approveContract };
