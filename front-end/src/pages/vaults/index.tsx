import React from "react";
import TableVault from "./components/TableVault";
const Vaults = () => {
  return (
    <section className="container">
      <div className="text-center text-2xl font-bold">FUND VAULTS</div>

      <div className="p-10">
        <TableVault />
      </div>
    </section>
  );
};

export default Vaults;
