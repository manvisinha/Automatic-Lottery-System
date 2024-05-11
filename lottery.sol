import React, {useState, useEffect} from "react";
import {ethers} from 'ethers';
import constants from './constants';

function Home() {
    const [currentAccount, setCurrentAccount] = useState("");
    const [contractInstance, setContractInstance] = useState(null);
    const [status, setStatus] = useState(false);
    const [isWinner, setIsWinner] = useState(false);

    useEffect(() => {
        const loadBlockchainData = async () => {
            if (typeof window.ethereum !== 'undefined') {
                try {
                    await window.ethereum.request({ method: 'eth_requestAccounts' });
                    const provider = new ethers.providers.Web3Provider(window.ethereum);
                    const signer = provider.getSigner();
                    const address = await signer.getAddress();
                    setCurrentAccount(address);
                    window.ethereum.on('accountsChanged', (accounts) => {
                        setCurrentAccount(accounts[0]);
                    });
                    const contractIns = new ethers.Contract(constants.contractAddress, constants.contractAbi, signer);
                    setContractInstance(contractIns);
                    const lotteryStatus = await contractIns.status();
                    setStatus(lotteryStatus);
                    const winner = await contractIns.getWinner();
                    setIsWinner(winner === address);
                } catch (err) {
                    console.error(err);
                }
            } else {
                alert('Please install Metamask to use this application');
            }
        };

        loadBlockchainData();
    }, []);

    const enterLottery = async () => {
        if (!contractInstance) return;
        try {
            const amountToSend = ethers.utils.parseEther('0.001');
            const tx = await contractInstance.enter({value: amountToSend});
            await tx.wait();
        } catch (err) {
            console.error(err);
        }
    };

    const claimPrize = async () => {
        if (!contractInstance) return;
        try {
            const tx = await contractInstance.claimPrize();
            await tx.wait();
        } catch (err) {
            console.error(err);
        }
    };

    return (
        <div className="container">
            <h1>Lottery Page</h1>
            <div className="button-container">
                {status ? (
                    isWinner ? (
                        <button className="enter-button" onClick={claimPrize}>Claim Prize</button>
                    ) : (
                        <p>You are not the winner</p>
                    )
                ) : (
                    <button className="enter-button" onClick={enterLottery}>Enter Lottery</button>
                )}
            </div>
        </div>
    );
}

export default Home;