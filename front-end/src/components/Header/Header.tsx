import Image from "next/image";
import Link from "next/link";
import Logo from "public/logo-web.png";

const Header = () => {
  return (
    <header className="container">
      <div className="flex justify-between items-center">
        <div>
          <Link href="/">
            {" "}
            <Image src={Logo} height={75} width={192} alt="" />
          </Link>
        </div>

        <nav>
          <ul className="flex items-center gap-6 justify-between font-medium text-base">
            <li className="hover:underline cursor-pointer transition-all">
              <Link href="/vaults"> FUND VAULTS</Link>
            </li>
            <li className="hover:underline cursor-pointer transition-all">
              <Link href="/dashboard"> DASHBOARD</Link>
            </li>
            <li className="hover:underline cursor-pointer transition-all">
              <Link href="/dashboard"> FAUCET</Link>
            </li>
            <li className="hover:underline cursor-pointer transition-all">
              <a
                href="https://github.com/terrancrypt/transfund#transfund"
                target="_blank"
              >
                {" "}
                DOCUMENTATION
              </a>
            </li>
          </ul>
        </nav>

        <w3m-button balance="hide" />
      </div>
    </header>
  );
};

export default Header;
