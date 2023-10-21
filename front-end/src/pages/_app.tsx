import React from "react";
import { createWeb3Modal, defaultWagmiConfig } from "@web3modal/wagmi/react";
import { ConfigProvider } from "antd";
import type { AppProps } from "next/app";
import { WagmiConfig } from "wagmi";
import { sepolia, polygonMumbai } from "wagmi/chains";
import Header from "@/components/Header/Header";
import "../styles/globals.css";

const projectId = "8113267d88fce267d26e0b99c63b53a6";

const metadata = {
  name: "Web3Modal",
  description: "Web3Modal Example",
  url: "https://web3modal.com",
  icons: ["https://avatars.githubusercontent.com/u/37784886"],
};

const chains = [sepolia, polygonMumbai];
const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata });

createWeb3Modal({ wagmiConfig, projectId, chains });

const App = ({ Component, pageProps }: AppProps) => (
  <ConfigProvider>
    <WagmiConfig config={wagmiConfig}>
      <Header />
      <Component {...pageProps} />
    </WagmiConfig>
  </ConfigProvider>
);

export default App;
