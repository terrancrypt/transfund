import React, { useEffect } from "react";
import { Space, Table, Tag, message } from "antd";
import type { ColumnsType } from "antd/es/table";
import { useAccount, useNetwork } from "wagmi";
import { getAllContractAddresses } from "@/contract-functions/interactEngineContract";

interface DataType {
  key: string;
  owner: string;
  asset: string;
  totalValue: number;
}

const columns: ColumnsType<DataType> = [
  {
    title: "Owner",
    dataIndex: "owner",
    key: "owner",
    render: (text) => <a>{text}</a>,
  },
  {
    title: "Asset",
    dataIndex: "asset",
    key: "asset",
  },
  {
    title: "Total Value",
    dataIndex: "totalValue",
    key: "totalValue",
  },
  {
    title: "",
    key: "action",
    render: (_, record) => <button>Invest</button>,
  },
];

const data: DataType[] = [
  {
    key: "1",
    owner: "John Brown",
    asset: "USDC",
    totalValue: 100,
  },
];

const App: React.FC = () => {
  // Wagmi
  const { address } = useAccount();
  const { chain } = useNetwork();
  console.log(chain);

  const fetchVaultAdresses = async () => {
    try {
      if (chain != undefined) {
        const result = await getAllContractAddresses(chain.id);
        console.log(result);
      }
    } catch (error) {
      message.error("Can't fetch data!");
      return null;
    }
  };

  useEffect(() => {
    fetchVaultAdresses();
  }, []);

  return <Table columns={columns} dataSource={data} pagination={false} />;
};

export default App;
