// Models/Entities
using Nethermind.Core.Crypto;
using Nethermind.Crypto;

namespace MedicalSystem.Models
{
    public enum UserType
    {
        Patient = 0,
        Doctor = 1,
        Admin = 2
    }

    public class UserInformation
    {
        [Key]
        public int UUID { get; set; }
        public byte[] EncryptedEmail { get; set; }
        public byte[] EncryptedPassword { get; set; }
        public UserType UserType { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class PatientGeneralInformation
    {
        [Key]
        public int Id { get; set; }
        public int UUID { get; set; }
        public byte[] EncryptedFullName { get; set; }
        public byte[] EncryptedGender { get; set; }
        public byte[] EncryptedDateOfBirth { get; set; }
        public byte[] EncryptedPhoneNumber { get; set; }
        public byte[] EncryptedCity { get; set; }
        public byte[] EncryptedState { get; set; }
        public byte[] EncryptedPostalCode { get; set; }
        public byte[] EncryptedPassportId { get; set; }
        public byte[] EncryptedEmergencyContact { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        
        public UserInformation UserInformation { get; set; }
    }

    public class PatientMedicalInformation
    {
        [Key]
        public string MedicationId { get; set; }
        public int UUID { get; set; }
        public byte[] EncryptedBloodType { get; set; }
        public byte[] EncryptedMedicationName { get; set; }
        public byte[] EncryptedDosage { get; set; }
        public byte[] EncryptedLastCheckup { get; set; }
        
        public UserInformation UserInformation { get; set; }
    }

    public class PatientAllergy
    {
        [Key]
        public int Id { get; set; }
        public int UUID { get; set; }
        public byte[] EncryptedAllergyName { get; set; }
        public byte[] EncryptedHasAllergy { get; set; }
        
        public UserInformation UserInformation { get; set; }
    }
}

// DbContext
namespace MedicalSystem.Data
{
    public class MedicalSystemContext : DbContext
    {
        public MedicalSystemContext(DbContextOptions<MedicalSystemContext> options, , IConfiguration configuration)
            : base(options)
        {
            _configuration = configuration;
        }

        public DbSet<UserInformation> UserInformation { get; set; }
        public DbSet<PatientGeneralInformation> PatientGeneralInformation { get; set; }
        public DbSet<PatientMedicalInformation> PatientMedicalInformation { get; set; }
        public DbSet<PatientAllergy> PatientAllergies { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                string connectionString = _configuration.GetConnectionString("DefaultConnection");
                optionsBuilder.UseSqlite(connectionString);
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure relationships
            modelBuilder.Entity<PatientGeneralInformation>()
                .HasOne(p => p.UserInformation)
                .WithMany()
                .HasForeignKey(p => p.UUID);

            modelBuilder.Entity<PatientMedicalInformation>()
                .HasOne(p => p.UserInformation)
                .WithMany()
                .HasForeignKey(p => p.UUID);

            modelBuilder.Entity<PatientAllergy>()
                .HasOne(p => p.UserInformation)
                .WithMany()
                .HasForeignKey(p => p.UUID);
        }
    }
}

// Encryption Service
namespace MedicalSystem.Services
{
    public interface IEncryptionService
    {
        byte[] Encrypt(string plainText, string key);
        string Decrypt(byte[] cipherText, string key);
    }

    public class EncryptionService : IEncryptionService
    {
        private readonly string _key;

        public EncryptionService(string key)
        {
            _key = key;
        }

        public byte[] Encrypt(string plainText, string key)
        {
            byte[] keyBytes = Encoding.UTF8.GetBytes(key);
            var keyHash = KeccakHash.Create().Hash(keyBytes);

            // Convert plain text to bytes
            byte[] plainTextBytes = Encoding.UTF8.GetBytes(plainText);
            
            // Use Nethermind's AesEcb implementation
            var encryptor = new AesEcb(keyHash);
            return encryptor.Encrypt(plainTextBytes);
        }

        public string Decrypt(byte[] cipherText, string key)
        {
            // Convert the key to bytes and hash it to get a consistent key length
            byte[] keyBytes = Encoding.UTF8.GetBytes(key);
            var keyHash = KeccakHash.Create().Hash(keyBytes);

            // Use Nethermind's AesEcb implementation
            var decryptor = new AesEcb(keyHash);
            byte[] decryptedBytes = decryptor.Decrypt(cipherText);
            
            // Convert decrypted bytes back to string
            return Encoding.UTF8.GetString(decryptedBytes);
        }
    }
}

// Patient Service
namespace MedicalSystem.Services
{
    public interface IPatientService
    {
        Task<bool> UpdateMedicalInformation(PatientMedicalInformation info);
        Task<PatientMedicalInformation> GetMedicalInformation(int uuid);
        Task<PatientGeneralInformation> GetGeneralInformation(int uuid);
        Task<bool> UpdateAllergies(PatientAllergy allergy);
    }

    public class PatientService : IPatientService
    {
        private readonly MedicalSystemContext _context;
        private readonly IEncryptionService _encryptionService;

        public PatientService(MedicalSystemContext context, IEncryptionService encryptionService)
        {
            _context = context;
            _encryptionService = encryptionService;
        }

        public async Task<bool> UpdateMedicalInformation(PatientMedicalInformation info)
        {
            var existing = await _context.PatientMedicalInformation
                .FirstOrDefaultAsync(p => p.UUID == info.UUID);

            if (existing == null)
            {
                _context.PatientMedicalInformation.Add(info);
            }
            else
            {
                _context.Entry(existing).CurrentValues.SetValues(info);
            }

            return await _context.SaveChangesAsync() > 0;
        }

        public async Task<PatientMedicalInformation> GetMedicalInformation(int uuid)
        {
            return await _context.PatientMedicalInformation
                .FirstOrDefaultAsync(p => p.UUID == uuid);
        }

        public async Task<PatientGeneralInformation> GetGeneralInformation(int uuid)
        {
            return await _context.PatientGeneralInformation
                .FirstOrDefaultAsync(p => p.UUID == uuid);
        }
        
        public async Task<bool> UpdateAllergies(PatientAllergy allergy)
        {
            var existing = await _context.PatientAllergies
                .FirstOrDefaultAsync(p => p.UUID == allergy.UUID);

            if (existing == null)
            {
                _context.PatientAllergies.Add(allergy);
            }
            else
            {
                _context.Entry(existing).CurrentValues.SetValues(allergy);
            }

            return await _context.SaveChangesAsync() > 0;
        }
    }
}

// API Controllers
namespace MedicalSystem.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PatientController : ControllerBase
    {
        private readonly IPatientService _patientService;
        private readonly IEncryptionService _encryptionService;

        public PatientController(IPatientService patientService, IEncryptionService encryptionService)
        {
            _patientService = patientService;
            _encryptionService = encryptionService;
        }

        [HttpPost("medical-info")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> UpdateMedicalInfo([FromBody] PatientMedicalInformationDTO dto)
        {
            var info = new PatientMedicalInformation
            {
                UUID = dto.UUID,
                EncryptedBloodType = _encryptionService.Encrypt(dto.BloodType, "your-encryption-key"),
                EncryptedMedicationName = _encryptionService.Encrypt(dto.MedicationName, "your-encryption-key"),
                EncryptedDosage = _encryptionService.Encrypt(dto.Dosage, "your-encryption-key"),
                EncryptedLastCheckup = _encryptionService.Encrypt(dto.LastCheckup.ToString(), "your-encryption-key")
            };

            var result = await _patientService.UpdateMedicalInformation(info);
            return result ? Ok() : BadRequest();
        }

        [HttpGet("medical-info/{uuid}")]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> GetMedicalInfo(int uuid)
        {
            var info = await _patientService.GetMedicalInformation(uuid);
            if (info == null) return NotFound();

            var dto = new PatientMedicalInformationDTO
            {
                UUID = info.UUID,
                BloodType = _encryptionService.Decrypt(info.EncryptedBloodType, "your-encryption-key"),
                MedicationName = _encryptionService.Decrypt(info.EncryptedMedicationName, "your-encryption-key"),
                Dosage = _encryptionService.Decrypt(info.EncryptedDosage, "your-encryption-key"),
                LastCheckup = DateTime.Parse(_encryptionService.Decrypt(info.EncryptedLastCheckup, "your-encryption-key"))
            };

            return Ok(dto);
        }

        [HttpGet("medical-info/{uuid}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetMedicalInfo(int uuid)
        {
            var info = await _patientService.GetGeneralInformation(uuid);
            if (info == null) return NotFound();

            var dto = new PatientGeneralInformationDTO
            {
                UUID = info.UUID,
                FullName = _encryptionService.Decrypt(info.EncryptedFullName, "your-encryption-key"),
                Gender = _encryptionService.Decrypt(info.EncryptedGender, "your-encryption-key"),
                DateOfBirth = _encryptionService.Decrypt(info.EncryptedDateOfBirth, "your-encryption-key"),
                PhoneNumber = _encryptionService.Decrypt(info.EncryptedPhoneNumber, "your-encryption-key"),
                City = _encryptionService.Decrypt(info.EncryptedCity, "your-encryption-key"),
                State = _encryptionService.Decrypt(info.EncryptedState, "your-encryption-key"),
                PostalCode = _encryptionService.Decrypt(info.EncryptedPostalCode, "your-encryption-key"),
                PassportId = _encryptionService.Decrypt(info.EncryptedPassportId, "your-encryption-key"),
                EmergencyContact = _encryptionService.Decrypt(info.EncryptedEmergencyContact, "your-encryption-key"),
                CreatedAt = info.CreatedAt,
                UpdatedAt = info.UpdatedAt
            };

            return Ok(dto);
        }
    }
}