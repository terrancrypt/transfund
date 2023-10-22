import React, { useEffect, useState } from "react";
import TableVault from "./components/TableVault";
import { useNetwork } from "wagmi";

const Vaults = () => {
  const { chain } = useNetwork();
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);
  return (
    <section className="container">
      <div className="text-center text-2xl font-bold pb-6">FUND VAULTS</div>

      <div>
        {isMounted && chain ? (
          <div className="p-10">
            <TableVault chainId={chain.id} />
          </div>
        ) : (
          <p className="text-center w-full">
            &quot;You need to connect your wallet to see this page!&quot;
          </p>
        )}
      </div>
    </section>
  );
};

export default Vaults;
