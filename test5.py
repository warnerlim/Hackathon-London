from web3 import Web3
from eth_account import Account
import hashlib
import json
from typing import Dict, List, Optional, TypedDict
from datetime import datetime
from enum import Enum
import logging

class PrescriptionStatus(Enum):
    PENDING = "PENDING"
    ACTIVE = "ACTIVE"
    FILLED = "FILLED"
    EXPIRED = "EXPIRED"
    CANCELLED = "CANCELLED"

class PrescriptionData(TypedDict):
    patient_address: str
    medication: str
    dosage: str
    frequency: str
    duration: str
    notes: Optional[str]
    created_at: str
    expiry_date: str

class HealthcareNetworkError(Exception):
    """Custom exception for healthcare network operations"""
    pass

class HealthcareNetwork:
    def __init__(self, config: Dict):
        """
        Initialize the healthcare network with configuration
        
        Args:
            config: Dict containing:
                - web3_provider: URL of the Web3 provider
                - contract_address: Address of the deployed contract
                - contract_abi: ABI of the deployed contract
                - private_key: Private key for transaction signing (optional)
        """
        try:
            self.web3 = Web3(Web3.HTTPProvider(config['web3_provider']))
            self.contract_address = config['contract_address']
            self.contract = self.web3.eth.contract(
                address=config['contract_address'],
                abi=config['contract_abi']
            )
            
            if 'private_key' in config:
                self.account = Account.from_key(config['private_key'])
            else:
                self.account = None
                
            logging.info("Healthcare network initialized successfully")
            
        except Exception as e:
            logging.error(f"Failed to initialize healthcare network: {str(e)}")
            raise HealthcareNetworkError(f"Initialization failed: {str(e)}")

    def _generate_hash(self, data: Dict) -> bytes:
        """
        Generate a deterministic hash from prescription data
        
        Args:
            data: Dictionary of prescription data
            
        Returns:
            bytes32 hash of the prescription data
        """
        try:
            formatted_data = json.dumps(data, sort_keys=True)
            prescription_hash = hashlib.sha256(formatted_data.encode()).hexdigest()
            return Web3.to_bytes(hexstr=prescription_hash)
        except Exception as e:
            logging.error(f"Hash generation failed: {str(e)}")
            raise HealthcareNetworkError(f"Hash generation failed: {str(e)}")

    async def create_prescription(self, prescription_data: PrescriptionData) -> Dict:
        """
        Create a new prescription on the blockchain
        
        Args:
            prescription_data: PrescriptionData containing all prescription details
            
        Returns:
            Dict containing prescription hash and transaction details
        """
        try:
            if not self.account:
                raise HealthcareNetworkError("Private key not configured for transaction signing")

            prescription_hash = self._generate_hash(prescription_data)
            
            tx = await self.contract.functions.createPrescription(
                prescription_hash,
                prescription_data['patient_address']
            ).build_transaction({
                'from': self.account.address,
                'nonce': self.web3.eth.get_transaction_count(self.account.address),
                'gas': 200000,
                'gasPrice': self.web3.eth.gas_price
            })
            
            signed_tx = self.web3.eth.account.sign_transaction(tx, self.account.key)
            tx_hash = self.web3.eth.send_raw_transaction(signed_tx.rawTransaction)
            receipt = self.web3.eth.wait_for_transaction_receipt(tx_hash)
            
            return {
                'prescription_hash': prescription_hash.hex(),
                'transaction_hash': tx_hash.hex(),
                'status': 'success' if receipt.status == 1 else 'failed',
                'block_number': receipt.blockNumber
            }
            
        except Exception as e:
            logging.error(f"Prescription creation failed: {str(e)}")
            raise HealthcareNetworkError(f"Prescription creation failed: {str(e)}")

    async def verify_prescription(self, prescription_hash: str) -> Dict:
        """
        Verify a prescription's validity
        
        Args:
            prescription_hash: Hash of the prescription to verify
            
        Returns:
            Dict containing prescription details and validity status
        """
        try:
            prescription_details = await self.contract.functions.getPrescriptionDetails(
                Web3.to_bytes(hexstr=prescription_hash)
            ).call()
            
            return {
                'patient': prescription_details[0],
                'doctor': prescription_details[1],
                'is_valid': prescription_details[2],
                'is_filled': prescription_details[3]
            }
            
        except Exception as e:
            logging.error(f"Prescription verification failed: {str(e)}")
            raise HealthcareNetworkError(f"Prescription verification failed: {str(e)}")

    async def get_patient_prescriptions(self, patient_address: str) -> List[Dict]:
        """
        Get all prescriptions for a patient
        
        Args:
            patient_address: Ethereum address of the patient
            
        Returns:
            List of prescription details
        """
        try:
            prescription_hashes = await self.contract.functions.getMyPrescriptions().call({
                'from': patient_address
            })
            
            prescriptions = []
            for prescription_hash in prescription_hashes:
                details = await self.verify_prescription(prescription_hash.hex())
                prescriptions.append({
                    'hash': prescription_hash.hex(),
                    **details
                })
                
            return prescriptions
            
        except Exception as e:
            logging.error(f"Failed to get patient prescriptions: {str(e)}")
            raise HealthcareNetworkError(f"Failed to get patient prescriptions: {str(e)}")

    async def fill_prescription(self, prescription_hash: str, pharmacy_address: str) -> Dict:
        """
        Fill a prescription (pharmacy function)
        
        Args:
            prescription_hash: Hash of the prescription to fill
            pharmacy_address: Address of the pharmacy filling the prescription
            
        Returns:
            Dict containing transaction details
        """
        try:
            if not self.account:
                raise HealthcareNetworkError("Private key not configured for transaction signing")

            tx = await self.contract.functions.verifyAndFillPrescription(
                Web3.to_bytes(hexstr=prescription_hash)
            ).build_transaction({
                'from': pharmacy_address,
                'nonce': self.web3.eth.get_transaction_count(pharmacy_address),
                'gas': 200000,
                'gasPrice': self.web3.eth.gas_price
            })
            
            signed_tx = self.web3.eth.account.sign_transaction(tx, self.account.key)
            tx_hash = self.web3.eth.send_raw_transaction(signed_tx.rawTransaction)
            receipt = self.web3.eth.wait_for_transaction_receipt(tx_hash)
            
            return {
                'transaction_hash': tx_hash.hex(),
                'status': 'success' if receipt.status == 1 else 'failed',
                'block_number': receipt.blockNumber
            }
            
        except Exception as e:
            logging.error(f"Prescription filling failed: {str(e)}")
            raise HealthcareNetworkError(f"Prescription filling failed: {str(e)}")

# Frontend helper functions
def create_prescription_data(
    patient_address: str,
    medication: str,
    dosage: str,
    frequency: str,
    duration: str,
    notes: str = "",
    expiry_days: int = 30
) -> PrescriptionData:
    """
    Create a properly formatted prescription data dictionary
    
    Args:
        patient_address: Ethereum address of the patient
        medication: Name of the medication
        dosage: Dosage information
        frequency: How often to take the medication
        duration: Duration of the prescription
        notes: Additional notes (optional)
        expiry_days: Number of days until prescription expires
        
    Returns:
        PrescriptionData dictionary
    """
    created_at = datetime.now().isoformat()
    expiry_date = (datetime.now() + timedelta(days=expiry_days)).isoformat()
    
    return PrescriptionData(
        patient_address=patient_address,
        medication=medication,
        dosage=dosage,
        frequency=frequency,
        duration=duration,
        notes=notes,
        created_at=created_at,
        expiry_date=expiry_date
    )

# Example frontend usage
async def example_frontend_usage():
    # Configuration
    config = {
        'web3_provider': 'http://localhost:8545',
        'contract_address': '0x...',
        'contract_abi': [...],  # Your contract ABI here
        'private_key': '0x...'  # Doctor's private key
    }
    
    # Initialize network
    network = HealthcareNetwork(config)
    
    # Create prescription data
    prescription_data = create_prescription_data(
        patient_address="0x123...",
        medication="Medication Name",
        dosage="10mg",
        frequency="twice daily",
        duration="30 days",
        notes="Take with food"
    )
    
    try:
        # Create prescription
        result = await network.create_prescription(prescription_data)
        print(f"Prescription created: {result}")
        
        # Verify prescription
        verification = await network.verify_prescription(result['prescription_hash'])
        print(f"Verification result: {verification}")
        
        # Get patient prescriptions
        prescriptions = await network.get_patient_prescriptions(prescription_data['patient_address'])
        print(f"Patient prescriptions: {prescriptions}")
        
    except HealthcareNetworkError as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(example_frontend_usage())