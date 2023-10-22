import React, { useEffect, useState } from "react";
import { useNetwork } from "wagmi";
import FaucetInformation from "./components/FaucetInformation";
import FaucetTable from "./components/FaucetTable";

const Faucet = () => {
  const { chain } = useNetwork();
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  return (
    <section className="container">
      <div className="text-center text-2xl font-bold">FAUCET</div>
      <div className="rounded-lg flex space-x-4 px-4 pt-6">
        {isMounted && chain ? (
          <>
            <FaucetInformation chainName={chain ? chain.name : ""} />
            <FaucetTable chainId={chain ? chain.id : ""} />
          </>
        ) : (
          <p className="text-center w-full">
            "You need to connect your wallet to see this page!"
          </p>
        )}
      </div>
    </section>
  );
};
export default Faucet;
