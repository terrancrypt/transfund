import Image from "next/image";
import { Inter } from "next/font/google";

const inter = Inter({ subsets: ["latin"] });

export default function Home() {
  return (
    <main className="flex items-center justify-center">
      <div>
        <p>
          This is a project built by{"  "}
          <a
            href="https://github.com/terrancrypt"
            target="_blank"
            className="underline"
          >
            terrancrypt
          </a>{" "}
          to participate in{"  "}
          <a
            href="https://ethglobal.com/events/ethonline2023"
            target="_blank"
            className="underline"
          >
            ETHGlobal's ETHOnline 2023
          </a>
          .
        </p>
        <p>
          To learn about the project, please read the {"  "}
          <a
            href="https://github.com/terrancrypt/transfund#transfund"
            target="_blank"
            className="underline"
          >
            documentation
          </a>
          .
        </p>
        <p>
          To use the protocol with investor features, please obtain the
          necessary tokens before use.
        </p>
        <p>
          You need to get ETH at{" "}
          <a
            href="https://sepoliafaucet.com/"
            target="_blank"
            className="underline"
          >
            Alchemy Sepolia Faucet
          </a>{" "}
          for transaction fees for Sepolia Testnet.
        </p>
        <p>
          You need to get MATIC at{" "}
          <a
            href="https://mumbaifaucet.com/"
            target="_blank"
            className="underline"
          >
            Alchemy Mumbai Faucet
          </a>{" "}
          for transaction fees for Mumbai Testnet.
        </p>
        <p>DAI and USDC, you can get at faucet.</p>
      </div>
    </main>
  );
}
