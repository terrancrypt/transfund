# Transfund

Dự án này nhằm mục đích giúp bất kỳ các cá nhân hay tổ chức đơn lẻ nào cũng có thể tạo và điều hành cho mình một quỹ mở. Các cá nhân tham gia được chia lợi nhuận theo lợi nhuận mà toàn bộ quỹ có.

## About 

Ý tưởng là dựa vào những tính nănng mà ERC4626 đem lại, tạo ra một giao thức mở tận dụng yếu tố decentralized của DeFi để:
 - Bất kỳ ai cũng có thể tạo ra và quản lý một quỹ, kêu gọi mọi người tham gia vào quỹ của mình.
 - Bất kỳ ai cũng có thể đầu tư vào một quỹ mở với các thông số của quỹ được công khai, lời ăn lỗ chịu.

Tận dụng và kết nối với các giao thức DeFi khác như DEX, Lending Market, Staking hoặc cung cấp thanh khoản cho một Liquidity Pools. Tuy nhiên, trong bản cuối cùng khi summit dự án này tại ETHGlobal tôi đã không có đủ thời gian để làm tất cả mọi thứ trong ý tưởng của mình mà chỉ bao gồm Uniswap. 

## FundVault

Ban đầu, dự định của tôi không hề liên quan dến ERC4626. Tuy nhiên, sau một khoản thời gian đau đầu vì không tìm được giải pháp cho việc chia sẻ lợi nhuận lại cho investor khi vault có lãi, tôi tình cờ tìm hiểu được ERC4626 và nó như một ốc đảo giữa sa mạc khi tôi phát triển dự án này.

Ngoài những tính năng cơ bản của ERC4626 thì tôi đã cải tiến và thêm vào một số HOOK.

Tính năng của FundVault:

- Cho phép Fund Manager tuỳ chọn những thiết lập ban đầu là: `_asset`(loại tài sản muốn thiết lập cho vault, USDC or DAI), `_basisPoint`(tỷ lệ phí ban đầu khi investor tham gia vào Vault), `_ownerSharesPercentage` (Số phần trăm nắm giữ của owner trong toàn bộ shares)
- `_asset`: (immutable) loại tài sản ở đây cho Fund Manager có thể thiết lập chỉ được sử dụng USDC hoặc DAI. Có thể trong tương lai tôi sẽ nâng cấp logic của dự án và thêm nhiều loại tài sản cho việc thiết lập Vault bằng cách bình chọn trong DAO.
- `_basisPoint`: (immutable) tỷ lệ phí ban đầu có thể bằng 0 hoặc tuỳ cách mà Fund Manager muốn thiết lập. Ví dụ: 100 = 1% tỷ lệ phí ban đầu. Khi có user mới tham gia vào Vault thì asset sẽ được chuyển thẳng đến địa chỉ ví của Fund Manager.
- `_ownerSharesPercentage`: (immutable) tỷ lệ này như một con số cam kết của Fund Manager dành cho các Investor của mình. Cho một ví dụ, nếu Fund Manager set tỷ lệ shares của họ có trong Vault là 10% thì khi họ deposit 10,000 USDC vào vault, vault sẽ có thể nạp tối đa 190,000 USDC từ các Investor. Điều này giúp Fund Manager chia sẻ rủi ro của họ trong Vault và xây dựng lòng tin của họ đối với các Investor. 

`_afterDeposit`: (immutable) function này giúp cho việc tính toán và nhận biết rằng khi nào thì FundManager và Investor nạp thêm tiền vào vault để tăng tỷ lệ cho vault.

Ví dụ về việc tăng tỷ lệ trong Vault:
- Thiết lập ban đầu của Fund Manager dành cho Vault là: `_asset` = USDC, `_basisPoint` = 100 (1%), `_ownerSharesPercentage` = 5 (5%).
_ Ban đầu nếu Fund Manager không nạp tiền vào Vault thì user sẽ không thể deposit, bởi vì ngay từ đầu Fund Manager đã cam kết sẽ mint 5% trên tổng shares của toàn bộ dự án. 
- Fund Manager quyết định nạp 10,000 USDC, theo tỷ lệ 5% họ đã cam kết ban đầu, bây giờ họ sẽ có thể quản lý một quỹ trị giá 200,000 USDC và user sẽ có thể deposit 95% trên tổng Vault.

Công thức cho điều này: Đầu tiên, chúng ta hãy đặt các biến như sau:

t = total shares can mint

m = new manager shares minted

p = manager shares percentage

i = investor deposited amount

![](./images/_afterDepositExample.png)

## Uniswap 
As part of this project, I forked uniswap v3 just to be able to make my idea a reality for this project. Still lacking many features that Uniswap offers.