// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Role-based access control interface
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
}

contract HealthcareNetwork {
    // Role definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");
    bytes32 public constant PHARMACY_ROLE = keccak256("PHARMACY_ROLE");
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");

    // Prescription struct
    struct Prescription {
        bytes32 prescriptionHash;
        address patient;
        address doctor;
        bool isValid;
        bool isFilled;
    }

    // State variables
    mapping(bytes32 => Prescription) public prescriptions;
    mapping(address => bytes32[]) public patientPrescriptions;
    IAccessControl public accessControl;

    // Events
    event PrescriptionCreated(bytes32 indexed prescriptionHash, address indexed patient, address indexed doctor);
    event PrescriptionFilled(bytes32 indexed prescriptionHash, address indexed pharmacy);

    constructor(address _accessControlAddress) {
        accessControl = IAccessControl(_accessControlAddress);
    }

    // Modifiers
    modifier onlyDoctor() {
        require(accessControl.hasRole(DOCTOR_ROLE, msg.sender), "Caller is not a doctor");
        _;
    }

    modifier onlyPharmacy() {
        require(accessControl.hasRole(PHARMACY_ROLE, msg.sender), "Caller is not a pharmacy");
        _;
    }

    modifier onlyPatient() {
        require(accessControl.hasRole(PATIENT_ROLE, msg.sender), "Caller is not a patient");
        _;
    }

    // Doctor functions
    function createPrescription(bytes32 _prescriptionHash, address _patient) external onlyDoctor {
        require(_patient != address(0), "Invalid patient address");
        require(!prescriptions[_prescriptionHash].isValid, "Prescription already exists");

        Prescription memory newPrescription = Prescription({
            prescriptionHash: _prescriptionHash,
            patient: _patient,
            doctor: msg.sender,
            isValid: true,
            isFilled: false
        });

        prescriptions[_prescriptionHash] = newPrescription;
        patientPrescriptions[_patient].push(_prescriptionHash);

        emit PrescriptionCreated(_prescriptionHash, _patient, msg.sender);
    }

    // Pharmacy functions
    function verifyAndFillPrescription(bytes32 _prescriptionHash) external onlyPharmacy {
        Prescription storage prescription = prescriptions[_prescriptionHash];
        require(prescription.isValid, "Invalid prescription");
        require(!prescription.isFilled, "Prescription already filled");

        prescription.isFilled = true;
        emit PrescriptionFilled(_prescriptionHash, msg.sender);
    }

    // Patient functions
    function getMyPrescriptions() external view onlyPatient returns (bytes32[] memory) {
        return patientPrescriptions[msg.sender];
    }

    function getPrescriptionDetails(bytes32 _prescriptionHash) external view returns (
        address patient,
        address doctor,
        bool isValid,
        bool isFilled
    ) {
        Prescription memory prescription = prescriptions[_prescriptionHash];
        require(
            msg.sender == prescription.patient ||
            accessControl.hasRole(DOCTOR_ROLE, msg.sender) ||
            accessControl.hasRole(PHARMACY_ROLE, msg.sender),
            "Unauthorized access"
        );

        return (
            prescription.patient,
            prescription.doctor,
            prescription.isValid,
            prescription.isFilled
        );
    }
}

contract AccessControl is IAccessControl {
    mapping(bytes32 => mapping(address => bool)) private _roles;
    address private _admin;

    constructor() {
        _admin = msg.sender;
        _roles[keccak256("ADMIN_ROLE")][msg.sender] = true;
    }

    modifier onlyAdmin() {
        require(_roles[keccak256("ADMIN_ROLE")][msg.sender], "Caller is not admin");
        _;
    }

    function hasRole(bytes32 role, address account) external view override returns (bool) {
        return _roles[role][account];
    }

    function grantRole(bytes32 role, address account) external override onlyAdmin {
        _roles[role][account] = true;
    }

    function revokeRole(bytes32 role, address account) external override onlyAdmin {
        _roles[role][account] = false;
    }
}