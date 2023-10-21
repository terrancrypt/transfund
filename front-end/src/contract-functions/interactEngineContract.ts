import { writeContract, readContract } from "@wagmi/core";
import EngineABI from "../abis/EngineAbi.json";
import { engineContract } from "./contractList";

// read
async function getAllContractAddresses(chainId: number) {
  const address = engineContract[chainId].address;
  try {
    const result = await readContract({
      address: address as any,
      abi: EngineABI as typeof EngineABI,
      functionName: "getFundVaultAddresses",
      chainId,
    });
    return result;
  } catch (error) {
    return null;
  }
}

export { getAllContractAddresses };
