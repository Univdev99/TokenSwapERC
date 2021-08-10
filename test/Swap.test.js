const GoldContract = artifacts.require("Gold");
const SilverContract = artifacts.require("Silver");
const SwapContract = artifacts.require("Swap");
const { expect } = require("chai");
const {
    BN,
    toWei,
    keccak256
} = require("web3-utils");

contract("Swap", (accounts) => {
    let Gold, Silver, Swap;

    before(async () => {
        await GoldContract.new()
        .then((instance) => {
            Gold = instance;
        })

        await SilverContract.new()
        .then((instance) => {
            Silver = instance;
        });

        await SwapContract.new(
            Gold.address,
            Silver.address,
            new BN(3), // transfer 5 * 10 ** 18. 1 token equals to 3 wei.
            new BN(2),
        ).then((instance) => {
            Swap = instance;
        });

        await Gold.transfer(Swap.address, new BN('10000000000000000000000'), { from: accounts[0] });
        await Silver.transfer(Swap.address, new BN('10000000000000000000000'), { from: accounts[0] });
    });

    describe("Swap", () => {
        it("Swap Eth to Gold token is working", async () => {
            await Swap.swapEthFor(keccak256("Swap(ETH, Gold)"), toWei(new BN(5)), {value: toWei(new BN(15)), from: accounts[1]});
            await Gold.balanceOf(accounts[1]).then(res => {
                expect(res.toString()).to.eq('5000000000000000000');
            });
            // console.log(await web3.eth.getBalance(accounts[1]));
            // console.log(await Gold.balanceOf(accounts[1]));
        });
        

        it("Swap Eth to Silver token is working", async () => {
            await Swap.swapEthFor(keccak256("Swap(ETH, Silver)"), toWei(new BN(5)), {value: toWei(new BN(10)), from: accounts[1]});
            await Silver.balanceOf(accounts[1]).then(res => {
                expect(res.toString()).to.eq('5000000000000000000');
            });
        });

        it("Swap Gold to ETH is working", async () => {
            await Gold.approve(Swap.address, toWei(new BN(5)), { from: accounts[1] });
            await Swap.swapTokenFor(keccak256("Swap(Gold, ETH)"), toWei(new BN(5)), {from: accounts[1]});
            await Gold.balanceOf(accounts[1]).then(res => {
                expect(res.toString()).to.eq('0');
            })
        });

        it("Swap Silver to ETH is working", async () => {
            await Silver.approve(Swap.address, toWei(new BN(5)), { from: accounts[1] });
            await Swap.swapTokenFor(keccak256("Swap(Silver, ETH)"), toWei(new BN(5)), {from: accounts[1]});
            await Silver.balanceOf(accounts[1]).then(res => {
                expect(res.toString()).to.eq('0');
            });
        });

        it("Swap Gold to Silver is working", async () => {
            await Gold.transfer(accounts[1], toWei(new BN(30)), { from: accounts[0] });
            await Gold.approve(Swap.address, toWei(new BN(30)), { from: accounts[1] });
            await Swap.swapTokenFor(keccak256("Swap(Gold, Silver)"), toWei(new BN(30)), {from: accounts[1]});
            await Gold.balanceOf(accounts[1]).then(res => {
                expect(res.toString()).to.eq('0');
            })
            await Silver.balanceOf(accounts[1]).then(res => {
                console.log(res.toString());
            });
        });

        it("Swap Silver to Gold is working", async () => {
            await Silver.transfer(accounts[2], toWei(new BN(30)), { from: accounts[0] });
            await Silver.approve(Swap.address, toWei(new BN(30)), { from: accounts[2] });
            await Swap.swapTokenFor(keccak256("Swap(Silver, Gold)"), toWei(new BN(30)), {from: accounts[2]});
            await Gold.balanceOf(accounts[2]).then(res => {
                expect(res.toString()).to.eq('45000000000000000000');
            })
            await Silver.balanceOf(accounts[2]).then(res => {
                expect(res.toString()).to.eq('0');
            });
        });
    });
});
