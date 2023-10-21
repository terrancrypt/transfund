import React from "react";
import { Space, Table, Tag } from "antd";
import type { ColumnsType } from "antd/es/table";

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

const App: React.FC = () => (
  <Table columns={columns} dataSource={data} pagination={false} />
);

export default App;
