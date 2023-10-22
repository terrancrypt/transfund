import { writeContract, readContract } from "@wagmi/core";
import EngineABI from "../abis/EngineAbi.json";
import { engineContract } from "./contractList";

// read
async function getAllContractAddresses(
  chainId: number
): Promise<string[] | null> {
  const address = engineContract[chainId].address;
  try {
    const result = await readContract({
      address: address as any,
      abi: EngineABI as typeof EngineABI,
      functionName: "getFundVaultAddresses",
      chainId,
    });
    return result as any;
  } catch (error) {
    console.log(error);
    return null;
  }
}

export { getAllContractAddresses };
