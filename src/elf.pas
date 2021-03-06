unit elf;

interface
uses SysUtils, Classes, Windows;

(*
/*
 * ELF definitions that are independent of architecture or word size.
 */

/*
 * Note header.  The ".note" section contains an array of notes.  Each
 * begins with this header, aligned to a word boundary.  Immediately
 * following the note header is n_namesz bytes of name, padded to the
 * next word boundary.  Then comes n_descsz bytes of descriptor, again
 * padded to a word boundary.  The values of n_namesz and n_descsz do
 * not include the padding.
 */
*)

type
//typedef unsigned __int64 uint64;
//typedef unsigned __int32 uint32;
//typedef unsigned __int16 uint16;
//typedef unsigned __int8 uint8;

//typedef __int64 int64;
//typedef __int32 int32;
//typedef __int16 int16;
//typedef __int8 int8;

Elf_Note = packed record
	n_namesz : uint32;	//* Length of name. */
	n_descsz : uint32;	//* Length of descriptor. */
	n_type : uint32;		//* Type of this note. */
end;

const
//* Indexes into the e_ident array.  Keep synced with
//   http://www.sco.com/developer/gabi/ch4.eheader.html */
EI_MAG0		= 0;//	/* Magic number, byte 0. */
EI_MAG1		= 1;//	/* Magic number, byte 1. */
EI_MAG2		= 2;//	/* Magic number, byte 2. */
EI_MAG3		= 3;//	/* Magic number, byte 3. */
EI_CLASS	= 4;//	/* Class of machine. */
EI_DATA		= 5;//	/* Data format. */
EI_VERSION	= 6;//	/* ELF format version. */
EI_OSABI	= 7;//	/* Operating system / ABI identification */
EI_ABIVERSION	= 8;//	/* ABI version */
OLD_EI_BRAND	= 8;//	/* Start of architecture identification. */
EI_PAD		= 9;//	/* Start of padding (per SVR4 ABI). */
EI_NIDENT	= 16;//	/* Size of e_ident array. */

//* Values for the magic number bytes. */
ELFMAG0	 =	$7f;
ELFMAG1	 =	'E';
ELFMAG2	 =	'L';
ELFMAG3	 =	'F';
ELFMAG	 =	'\177ELF';	//* magic string */ 사용안되는거 같음 //
//#define ELFMAG		"\177ELF"	/* magic string */
SELFMAG	 =	4;//		/* magic string size */ 사용안되는거 같음 //

//* Values for e_ident[EI_VERSION] and e_version. */
EV_NONE	 =	0;
EV_CURRENT	= 1;

//* Values for e_ident[EI_CLASS]. */
ELFCLASSNONE=	0;//	/* Unknown class. */
ELFCLASS32	= 1;//	/* 32-bit architecture. */
ELFCLASS64	= 2;//	/* 64-bit architecture. */

//* Values for e_ident[EI_DATA]. */
ELFDATANONE	= 0;//	/* Unknown data format. */
ELFDATA2LSB	= 1;//	/* 2's complement little-endian. */
ELFDATA2MSB	= 2;//	/* 2's complement big-endian. */

///* Values for e_ident[EI_OSABI]. */
ELFOSABI_NONE		 = 0;//	/* UNIX System V ABI */
ELFOSABI_HPUX		 = 1;//	/* HP-UX operating system */
ELFOSABI_NETBSD	 = 2;//	/* NetBSD */
ELFOSABI_LINUX	 = 3;//	/* GNU/Linux */
ELFOSABI_HURD		 = 4;//	/* GNU/Hurd */
ELFOSABI_86OPEN	 = 5;//	/* 86Open common IA32 ABI */
ELFOSABI_SOLARIS = 6;//	/* Solaris */
ELFOSABI_AIX	   = 7;//	/* AIX */
ELFOSABI_IRIX		 = 8;//	/* IRIX */
ELFOSABI_FREEBSD = 9;//	/* FreeBSD */
ELFOSABI_TRU64	 = 10;//	/* TRU64 UNIX */
ELFOSABI_MODESTO = 11;//	/* Novell Modesto */
ELFOSABI_OPENBSD = 12;//	/* OpenBSD */
ELFOSABI_OPENVMS = 13;//	/* Open VMS */
ELFOSABI_NSK		 = 14;//	/* HP Non-Stop Kernel */
ELFOSABI_ARM		 = 97;//	/* ARM */
ELFOSABI_STANDALONE =	255;//	/* Standalone (embedded) application */

ELFOSABI_SYSV	=	ELFOSABI_NONE;//	/* symbol used in old spec */
ELFOSABI_MONTEREY	= ELFOSABI_AIX;//	/* Monterey */

//* e_ident */ 아직 사용 안되는것 같음 //
//#define IS_ELF(ehdr)	((ehdr).e_ident[EI_MAG0] == ELFMAG0 && \
//			 (ehdr).e_ident[EI_MAG1] == ELFMAG1 && \
//			 (ehdr).e_ident[EI_MAG2] == ELFMAG2 && \
//			 (ehdr).e_ident[EI_MAG3] == ELFMAG3)

//* Values for e_type. */
ET_NONE	 =	0;//	/* Unknown type. */
ET_REL	 =	1;//	/* Relocatable. */
ET_EXEC	 =	2;//	/* Executable. */
ET_DYN	 =	3;//	/* Shared object. */
ET_CORE	 =	4;//	/* Core file. */
ET_LOOS	 =	$fe00;//	/* First operating system specific. */
ET_HIOS	 =	$feff;//	/* Last operating system-specific. */
ET_LOPROC=	$ff00;//	/* First processor-specific. */
ET_HIPROC=	$ffff;//	/* Last processor-specific. */

///* Values for e_machine. */
EM_NONE	 =	0;//	/* Unknown machine. */
EM_M32	 =	1;//	/* AT&T WE32100. */
EM_SPARC =	2;//	/* Sun SPARC. */
EM_386	 =	3;//	/* Intel i386. */
EM_68K	 =	4;//	/* Motorola 68000. */
EM_88K	 =	5;//	/* Motorola 88000. */
EM_860	 =	7;//	/* Intel i860. */
EM_MIPS	 =	8;//	/* MIPS R3000 Big-Endian only. */
EM_S370	 =	9;//	/* IBM System/370. */
EM_MIPS_RS3_LE =	10;//	/* MIPS R3000 Little-Endian. */
EM_PARISC	=15;//	/* HP PA-RISC. */
EM_VPP500	=17;//	/* Fujitsu VPP500. */
EM_SPARC32PLUS =	18;//	/* SPARC v8plus. */
EM_960	 =	19;//	/* Intel 80960. */
EM_PPC	 =	20;//	/* PowerPC 32-bit. */
EM_PPC64 =	21;//	/* PowerPC 64-bit. */
EM_S390	 =	22;//	/* IBM System/390. */
EM_V800	 =	36;//	/* NEC V800. */
EM_FR20	 =	37;//	/* Fujitsu FR20. */
EM_RH32	 =	38;//	/* TRW RH-32. */
EM_RCE	 =	39;//	/* Motorola RCE. */
EM_ARM	 =	40;//	/* ARM. */
EM_SH		=42;//	/* Hitachi SH. */
EM_SPARCV9 =	43;//	/* SPARC v9 64-bit. */
EM_TRICORE =	44;//	/* Siemens TriCore embedded processor. */
EM_ARC	 =	45;//	/* Argonaut RISC Core. */
EM_H8_300	=46;//	/* Hitachi H8/300. */
EM_H8_300H	=47;//	/* Hitachi H8/300H. */
EM_H8S		=48;//	/* Hitachi H8S. */
EM_H8_500	=49;//	/* Hitachi H8/500. */
EM_IA_64	=50;//	/* Intel IA-64 Processor. */
EM_MIPS_X	=51;//	/* Stanford MIPS-X. */
EM_COLDFIRE	=52;//	/* Motorola ColdFire. */
EM_68HC12	=53;//	/* Motorola M68HC12. */
EM_MMA		=54;//	/* Fujitsu MMA. */
EM_PCP		=55;//	/* Siemens PCP. */
EM_NCPU		=56;//	/* Sony nCPU. */
EM_NDR1		=57;//	/* Denso NDR1 microprocessor. */
EM_STARCORE	=58;//	/* Motorola Star*Core processor. */
EM_ME16		=59;//	/* Toyota ME16 processor. */
EM_ST100	=60;//	/* STMicroelectronics ST100 processor. */
EM_TINYJ	=61;//	/* Advanced Logic Corp. TinyJ processor. */
EM_X86_64	=62;//	/* Advanced Micro Devices x86-64 */

///* Non-standard or deprecated. */
EM_486	 =	6;//	/* Intel i486. */
EM_MIPS_RS4_BE	=10;//	/* MIPS R4000 Big-Endian */
EM_ALPHA_STD	=41;//	/* Digital Alpha (standard value). */
EM_ALPHA	=$9026;//	/* Alpha (written in the absence of an ABI) */

//* Special section indexes. */
SHN_UNDEF	    = 0;//		/* Undefined, missing, irrelevant. */
SHN_LORESERVE	=$ff00;//		/* First of reserved range. */
SHN_LOPROC	=$ff00;//		/* First processor-specific. */
SHN_HIPROC	=$ff1f;//		/* Last processor-specific. */
SHN_LOOS	=$ff20;//		/* First operating system-specific. */
SHN_HIOS	=$ff3f;//		/* Last operating system-specific. */
SHN_ABS		=$fff1;//		/* Absolute values. */
SHN_COMMON	=$fff2;//		/* Common data. */
SHN_XINDEX	=$ffff;//		/* Escape -- index stored elsewhere. */
SHN_HIRESERVE	=$ffff;//		/* Last of reserved range. */

//* sh_type */
SHT_NULL	=	0;//	/* inactive */
SHT_PROGBITS =		1;//	/* program defined information */
SHT_SYMTAB	 =	2;//	/* symbol table section */
SHT_STRTAB	 =	3;//	/* string table section */
SHT_RELA		=4;//	/* relocation section with addends */
SHT_HASH		=5;//	/* symbol hash table section */
SHT_DYNAMIC	=	6;//	/* dynamic section */
SHT_NOTE	 =	7;//	/* note section */
SHT_NOBITS	=	8;//	/* no space section */
SHT_REL		 =	9;//	/* relocation section - no addends */
SHT_SHLIB	 =	10;//	/* reserved - purpose unknown */
SHT_DYNSYM	=	11;//	/* dynamic symbol table section */
SHT_INIT_ARRAY =		14;//	/* Initialization function pointers. */
SHT_FINI_ARRAY	=	15;//	/* Termination function pointers. */
SHT_PREINIT_ARRAY	=16;//	/* Pre-initialization function ptrs. */
SHT_GROUP		=17;//	/* Section group. */
SHT_SYMTAB_SHNDX =	18;//	/* Section indexes (see SHN_XINDEX). */
SHT_LOOS	=$60000000;//	/* First of OS specific semantics */
SHT_HIOS	=$6fffffff;//	/* Last of OS specific semantics */
SHT_GNU_VERDEF	=$6ffffffd;
SHT_GNU_VERNEED	=$6ffffffe;
SHT_GNU_VERSYM	=$6fffffff;
SHT_LOPROC	=$70000000;//	/* reserved range for processor */
SHT_HIPROC	=$7fffffff;//	/* specific section header types */
SHT_LOUSER	=$80000000;//	/* reserved range for application */
SHT_HIUSER	=$ffffffff;//	/* specific indexes */

//* Flags for sh_flags. */
SHF_WRITE		=$1;//	/* Section contains writable data. */
SHF_ALLOC		=$2;//	/* Section occupies memory. */
SHF_EXECINSTR	=	$4;//	/* Section contains instructions. */
SHF_MERGE		=$10;//	/* Section may be merged. */
SHF_STRINGS	 =	$20;//	/* Section contains strings. */
SHF_INFO_LINK	 =	$40;//	/* sh_info holds section index. */
SHF_LINK_ORDER	=	$80;//	/* Special ordering requirements. */
SHF_OS_NONCONFORMING =	$100;//	/* OS-specific processing required. */
SHF_GROUP	 =	$200;//	/* Member of section group. */
SHF_TLS		 =	$400;//	/* Section contains TLS data. */
SHF_MASKOS	=$0ff00000;//	/* OS-specific semantics. */
SHF_MASKPROC	=$f0000000;//	/* Processor-specific semantics. */

//* Values for p_type. */
PT_NULL		=0;//	/* Unused entry. */
PT_LOAD		=1;//	/* Loadable segment. */
PT_DYNAMIC=	2;//	/* Dynamic linking information segment. */
PT_INTERP	=3;//	/* Pathname of interpreter. */
PT_NOTE		=4;//	/* Auxiliary information. */
PT_SHLIB	=5;//	/* Reserved (not used). */
PT_PHDR		=6;//	/* Location of program header itself. */
PT_TLS		=7;//	/* Thread local storage segment */
PT_LOOS		=$60000000;//	/* First OS-specific. */
PT_HIOS		=$6fffffff;//	/* Last OS-specific. */
PT_LOPROC	=$70000000;//	/* First processor-specific type. */
PT_HIPROC	=$7fffffff;//	/* Last processor-specific type. */
PT_GNU_STACK =	$6474e551;
PT_PAX_FLAGS =	$65041580;

//* Values for p_flags. */
PF_X		=$1;//		/* Executable. */
PF_W		=$2;//		/* Writable. */
PF_R		=$4;//		/* Readable. */
PF_MASKOS	=$0ff00000;//	/* Operating system-specific. */
PF_MASKPROC	=$f0000000;//	/* Processor-specific. */

//* Values for d_tag. */
DT_NULL		= 0;//	/* Terminating entry. */
//* String table offset of a needed shared library. */
DT_NEEDED	=1;
DT_PLTRELSZ	=2;//	/* Total size in bytes of PLT relocations. */
DT_PLTGOT	=3;//	/* Processor-dependent address. */
DT_HASH		=4;//	/* Address of symbol hash table. */
DT_STRTAB	=5;//	/* Address of string table. */
DT_SYMTAB	=6;//	/* Address of symbol table. */
DT_RELA		=7;//	/* Address of ElfNN_Rela relocations. */
DT_RELASZ	=8;//	/* Total size of ElfNN_Rela relocations. */
DT_RELAENT =	9;//	/* Size of each ElfNN_Rela relocation entry. */
DT_STRSZ	=10;//	/* Size of string table. */
DT_SYMENT	=11;//	/* Size of each symbol table entry. */
DT_INIT		=12;//	/* Address of initialization function. */
DT_FINI		=13;//	/* Address of finalization function. */
//* String table offset of shared object name. */
DT_SONAME	=14;
DT_RPATH	=15;//	/* String table offset of library path. [sup] */
DT_SYMBOLIC	=16;//	/* Indicates "symbolic" linking. [sup] */
DT_REL		=17;//	/* Address of ElfNN_Rel relocations. */
DT_RELSZ	=18;//	/* Total size of ElfNN_Rel relocations. */
DT_RELENT	=19;//	/* Size of each ElfNN_Rel relocation. */
DT_PLTREL	=20;//	/* Type of relocation used for PLT. */
DT_DEBUG	=21;//	/* Reserved (not used). */
//* Indicates there may be relocations in non-writable segments. [sup] */
DT_TEXTREL	=22;
DT_JMPREL	=23;//	/* Address of PLT relocations. */
DT_BIND_NOW	=24;//	/* [sup] */
//* Address of the array of pointers to initialization functions */
DT_INIT_ARRAY	=25;
//* Address of the array of pointers to termination functions */
DT_FINI_ARRAY	=26;
//* Size in bytes of the array of initialization functions. */
DT_INIT_ARRAYSZ	=27;
//* Size in bytes of the array of terminationfunctions. */
DT_FINI_ARRAYSZ	=28;
//* String table offset of a null-terminated library search path string. */
DT_RUNPATH	=29 ;
DT_FLAGS	=30;//	/* Object specific flag values. */
//*	Values greater than or equal to DT_ENCODING and less than
//	DT_LOOS follow the rules for the interpretation of the d_un
//	union as follows: even == 'd_ptr', even == 'd_val' or none */
DT_ENCODING	=32;
///* Address of the array of pointers to pre-initialization functions. */
DT_PREINIT_ARRAY =32;
//* Size in bytes of the array of pre-initialization functions. */
DT_PREINIT_ARRAYSZ =33;
DT_LOOS		=$6000000d;//	/* First OS-specific */
DT_HIOS		=$6ffff000;//	/* Last OS-specific */
DT_LOPROC	=$70000000;//	/* First processor-specific type. */
DT_HIPROC	=$7fffffff;//	/* Last processor-specific type. */

DT_VERNEED	= $6ffffffe;
DT_VERNEEDNUM	=$6fffffff;
DT_VERSYM	=$6ffffff0;

//* Values for DT_FLAGS */
//*	Indicates that the object being loaded may make reference to
//	the $ORIGIN substitution string */
DF_ORIGIN	=$0001;
DF_SYMBOLIC	=$0002;//	/* Indicates "symbolic" linking. */
//* Indicates there may be relocations in non-writable segments. */
DF_TEXTREL	= $0004;//
//*	Indicates that the dynamic linker should process all
//	relocations for the object containing this entry before
//	transferring control to the program.  */
DF_BIND_NOW	= $0008;//
///*	Indicates that the shared object or executable contains code
//	using a static thread-local storage scheme.  */
DF_STATIC_TLS	= $0010;//

//* Values for n_type.  Used in core files. */
NT_PRSTATUS	=1;//	/* Process status. */
NT_FPREGSET	=2;//	/* Floating point registers. */
NT_PRPSINFO	=3;//	/* Process state info. */

//* Symbol Binding - ELFNN_ST_BIND - st_info */
STB_LOCAL	=0;//	/* Local symbol */
STB_GLOBAL	=1;//	/* Global symbol */
STB_WEAK	=2;//	/* like global - lower precedence */
STB_LOOS	=10;//	/* Reserved range for operating system */
STB_HIOS	=12;//	/*   specific semantics. */
STB_LOPROC	=13;//	/* reserved range for processor */
STB_HIPROC	=15 ;//	/*   specific semantics. */

//* Symbol type - ELFNN_ST_TYPE - st_info */
STT_NOTYPE	=0;//	/* Unspecified type. */
STT_OBJECT	=1;//	/* Data object. */
STT_FUNC	=2;//	/* Function. */
STT_SECTION	=3;//	/* Section. */
STT_FILE	=4	;///* Source file. */
STT_COMMON	=5;//	/* Uninitialized common block. */
STT_TLS		=6;//	/* TLS object. */
STT_LOOS	=10;//	/* Reserved range for operating system */
STT_HIOS	=12 ;//	/*   specific semantics. */
STT_LOPROC	=13;//	/* reserved range for processor */
STT_HIPROC	=15;//	/*   specific semantics. */

//* Symbol visibility - ELFNN_ST_VISIBILITY - st_other */
STV_DEFAULT	=$0;//	/* Default visibility (see binding). */
STV_INTERNAL	=$1;//	/* Special meaning in relocatable objects. */
STV_HIDDEN	=$2;//	/* Not visible. */
STV_PROTECTED	=$3;//	/* Visible but not preemptible. */

//* Special symbol table indexes. */
STN_UNDEF	=0;//	/* Undefined symbol index. */


//*
// * ELF definitions common to all 32-bit architectures.
// */

type
Elf32_Addr = uint32;
Elf32_Half = uint16;
Elf32_Off = uint32;
Elf32_Sword = int32;
Elf32_Word = uint32;

Elf32_Hashelt = Elf32_Word;

//* Non-standard class-dependent datatype used for abstraction. */
Elf32_Size = Elf32_Word;
Elf32_Ssize = Elf32_Sword;

//*
// * ELF header.
// */

type
Elf32_Ehdr = packed record
	ident : array [0..EI_NIDENT-1] of UCHAR;	//* File identification. */
	type_ : Elf32_Half;		//* File type. */
	machine : Elf32_Half;	//* Machine architecture. */
	version : Elf32_Word;	//* ELF format version. */
	entry : Elf32_Addr;	//* Entry point. */
	phoff : Elf32_Off;	//* Program header file offset. */
	shoff : Elf32_Off;	//* Section header file offset. */
	flags : Elf32_Word;	//* Architecture-specific flags. */
	ehsize : Elf32_Half;	//* Size of ELF header in bytes. */
	phentsize : Elf32_Half;	//* Size of program header entry. */
	phnum : Elf32_Half;	//* Number of program header entries. */
	shentsize : Elf32_Half;	//* Size of section header entry. */
	shnum : Elf32_Half;	//* Number of section header entries. */
	shstrndx : Elf32_Half;	//* Section name strings section. */
end;

///*
// * Section header.
// */

Elf32_Shdr = packed record
	name : Elf32_Word;	//* Section name (index into the
					   //section header string table). */
	type_ : Elf32_Word;	//* Section type. */
	flags : Elf32_Word;	//* Section flags. */
	vaddr : Elf32_Addr;	//* Address in memory image. */
	off : Elf32_Off;	//* Offset in file. */
	size : Elf32_Word;	//* Size in bytes. */
	link : Elf32_Word;	//* Index of a related section. */
	info : Elf32_Word;	//* Depends on section type. */
	addralign : Elf32_Word;	//* Alignment in bytes. */
	entsize : Elf32_Word;	//* Size of each entry in section. */
end;

///*
// * Program header.
// */

Elf32_Phdr = packed record
	type_ : Elf32_Word;		//* Entry type. */
	off : Elf32_Off; //* File offset of contents. */
	vaddr : Elf32_Addr;	//* Virtual address in memory image. */
	paddr : Elf32_Addr;	//* Physical address (not used). */
	filesz : Elf32_Word;	//* Size of contents in file. */
	memsz : Elf32_Word;	//* Size of contents in memory. */
	flags : Elf32_Word;	//* Access permission flags. */
	align : Elf32_Word;	//* Alignment in memory and file. */
end;

//*
// * Dynamic structure.  The ".dynamic" section contains an array of them.
// */

Elf32_Dyn = packed record
	d_tag : Elf32_Sword;		//* Entry type. */
	case Integer of
  0 : (d_val : Elf32_Word);	//* Integer value. */
	1 : (d_ptr : Elf32_Addr);	//* Address value. */
end;

//*
// * Relocation entries.
// */

///* Relocations that don't need an addend field. */
Elf32_Rel = packed record
	off : Elf32_Addr;	//* Location to be relocated. */
	info : Elf32_Word;		//* Relocation type and symbol index. */
end;

//* Relocations that need an addend field. */
Elf32_Rela = packed record
	off : Elf32_Addr;	//* Location to be relocated. */
	info : Elf32_Word;		//* Relocation type and symbol index. */
	addend : Elf32_Sword;	//* Addend. */
end;

//* Macros for accessing the fields of r_info. */
//ELF32_R_SYM(info)	((info) >> 8)
//ELF32_R_TYPE(info)	((unsigned char)(info))

///* Macro for constructing r_info from field values. */
//#define ELF32_R_INFO(sym, type)	(((sym) << 8) + (unsigned char)(type))

const
///*
// * Relocation types.
// */
R_X86_64_NONE	=0	;//* No relocation. */
R_X86_64_64	=1	;//* Add 64 bit symbol value. */
R_X86_64_PC32	=2	;//* PC-relative 32 bit signed sym value. */
R_X86_64_GOT32	=3	;//* PC-relative 32 bit GOT offset. */
R_X86_64_PLT32	=4	;//* PC-relative 32 bit PLT offset. */
R_X86_64_COPY	=5	;//* Copy data from shared object. */
R_X86_64_GLOB_DAT =6	;//* Set GOT entry to data address. */
R_X86_64_JMP_SLOT =7	;//* Set GOT entry to code address. */
R_X86_64_RELATIVE =8	;//* Add load address of shared object. */
R_X86_64_GOTPCREL =9	;//* Add 32 bit signed pcrel offset to GOT. */
R_X86_64_32	=10	;//* Add 32 bit zero extended symbol value */
R_X86_64_32S	=11	;//* Add 32 bit sign extended symbol value */
R_X86_64_16	=12	;//* Add 16 bit zero extended symbol value */
R_X86_64_PC16	=13	;//* Add 16 bit signed extended pc relative symbol value */
R_X86_64_8	=14	;//* Add 8 bit zero extended symbol value */
R_X86_64_PC8	=15	;//* Add 8 bit signed extended pc relative symbol value */
R_X86_64_DTPMOD64 =16	;//* ID of module containing symbol */
R_X86_64_DTPOFF64 =17	;//* Offset in TLS block */
R_X86_64_TPOFF64 =18	;//* Offset in static TLS block */
R_X86_64_TLSGD	=19	;//* PC relative offset to GD GOT entry */
R_X86_64_TLSLD	=20	;//* PC relative offset to LD GOT entry */
R_X86_64_DTPOFF32 =21	;//* Offset in TLS block */
R_X86_64_GOTTPOFF =22	;//* PC relative offset to IE GOT entry */
R_X86_64_TPOFF32 =23	;//* Offset in static TLS block */

R_X86_64_COUNT	=24	;//* Count of defined relocation types. */


R_ALPHA_NONE		=0	;//* No reloc */
R_ALPHA_REFLONG		=1	;//* Direct 32 bit */
R_ALPHA_REFQUAD		=2	;//* Direct 64 bit */
R_ALPHA_GPREL32		=3	;//* GP relative 32 bit */
R_ALPHA_LITERAL		=4	;//* GP relative 16 bit w/optimization */
R_ALPHA_LITUSE		=5	;//* Optimization hint for LITERAL */
R_ALPHA_GPDISP		=6	;//* Add displacement to GP */
R_ALPHA_BRADDR		=7	;//* PC+4 relative 23 bit shifted */
R_ALPHA_HINT		=8	;//* PC+4 relative 16 bit shifted */
R_ALPHA_SREL16		=9	;//* PC relative 16 bit */
R_ALPHA_SREL32		=10	;//* PC relative 32 bit */
R_ALPHA_SREL64		=11	;//* PC relative 64 bit */
R_ALPHA_OP_PUSH		=12	;//* OP stack push */
R_ALPHA_OP_STORE	=13	;//* OP stack pop and store */
R_ALPHA_OP_PSUB		=14	;//* OP stack subtract */
R_ALPHA_OP_PRSHIFT	=15	;//* OP stack right shift */
R_ALPHA_GPVALUE		=16;
R_ALPHA_GPRELHIGH	=17;
R_ALPHA_GPRELLOW	=18;
R_ALPHA_IMMED_GP_16	=19;
R_ALPHA_IMMED_GP_HI32	=20;
R_ALPHA_IMMED_SCN_HI32	=21;
R_ALPHA_IMMED_BR_HI32	=22;
R_ALPHA_IMMED_LO32	=23;
R_ALPHA_COPY		=24	;//* Copy symbol at runtime */
R_ALPHA_GLOB_DAT	=25	;//* Create GOT entry */
R_ALPHA_JMP_SLOT	=26	;//* Create PLT entry */
R_ALPHA_RELATIVE	=27	;//* Adjust by program base */

R_ALPHA_COUNT		=28;


R_ARM_NONE		=0	;//* No relocation. */
R_ARM_PC24		=1;
R_ARM_ABS32		=2;
R_ARM_REL32		=3;
R_ARM_PC13		=4;
R_ARM_ABS16		=5;
R_ARM_ABS12		=6;
R_ARM_THM_ABS5		=7;
R_ARM_ABS8		=8;
R_ARM_SBREL32		=9;
R_ARM_THM_PC22		=10;
R_ARM_THM_PC8		=11;
R_ARM_AMP_VCALL9	=12;
R_ARM_SWI24		=13;
R_ARM_THM_SWI8		=14;
R_ARM_XPC25		=15;
R_ARM_THM_XPC22		=16;
R_ARM_COPY		=20	;//* Copy data from shared object. */
R_ARM_GLOB_DAT		=21	;//* Set GOT entry to data address. */
R_ARM_JUMP_SLOT		=22	;//* Set GOT entry to code address. */
R_ARM_RELATIVE		=23	;//* Add load address of shared object. */
R_ARM_GOTOFF		=24	;//* Add GOT-relative symbol address. */
R_ARM_GOTPC		=25	;//* Add PC-relative GOT table address. */
R_ARM_GOT32		=26	;//* Add PC-relative GOT offset. */
R_ARM_PLT32		=27	;//* Add PC-relative PLT offset. */
R_ARM_CALL		=28;
R_ARM_JUMP24	=29;
R_ARM_V4BX		=40;
R_ARM_GOT_PREL		=96;
R_ARM_GNU_VTENTRY	=100;
R_ARM_GNU_VTINHERIT	=101;
R_ARM_TLS_IE32		=107;
R_ARM_TLS_LE32		=108;
R_ARM_RSBREL32		=250;
R_ARM_THM_RPC22		=251;
R_ARM_RREL32		=252;
R_ARM_RABS32		=253;
R_ARM_RPC24		=254;
R_ARM_RBASE		=255;

R_ARM_COUNT		=38	;//* Count of defined relocation types. */


R_386_NONE	=0	;//* No relocation. */
R_386_32	=1	;//* Add symbol value. */
R_386_PC32	=2	;//* Add PC-relative symbol value. */
R_386_GOT32	=3	;//* Add PC-relative GOT offset. */
R_386_PLT32	=4	;//* Add PC-relative PLT offset. */
R_386_COPY	=5	;//* Copy data from shared object. */
R_386_GLOB_DAT	=6	;//* Set GOT entry to data address. */
R_386_JMP_SLOT	=7	;//* Set GOT entry to code address. */
R_386_RELATIVE	=8	;//* Add load address of shared object. */
R_386_GOTOFF	=9	;//* Add GOT-relative symbol address. */
R_386_GOTPC	=10	;//* Add PC-relative GOT table address. */
R_386_TLS_TPOFF	=14	;//* Negative offset in static TLS block */
R_386_TLS_IE	=15	;//* Absolute address of GOT for -ve static TLS */
R_386_TLS_GOTIE	=16	;//* GOT entry for negative static TLS block */
R_386_TLS_LE	=17	;//* Negative offset relative to static TLS */
R_386_TLS_GD	=18	;//* 32 bit offset to GOT (index,off) pair */
R_386_TLS_LDM	=19	;//* 32 bit offset to GOT (index,zero) pair */
R_386_TLS_GD_32	=24	;//* 32 bit offset to GOT (index,off) pair */
R_386_TLS_GD_PUSH =25	;//* pushl instruction for Sun ABI GD sequence */
R_386_TLS_GD_CALL =26	;//* call instruction for Sun ABI GD sequence */
R_386_TLS_GD_POP =27	;//* popl instruction for Sun ABI GD sequence */
R_386_TLS_LDM_32 =28	;//* 32 bit offset to GOT (index,zero) pair */
R_386_TLS_LDM_PUSH =29	;//* pushl instruction for Sun ABI LD sequence */
R_386_TLS_LDM_CALL =30	;//* call instruction for Sun ABI LD sequence */
R_386_TLS_LDM_POP =31	;//* popl instruction for Sun ABI LD sequence */
R_386_TLS_LDO_32 =32	;//* 32 bit offset from start of TLS block */
R_386_TLS_IE_32	=33	;//* 32 bit offset to GOT static TLS offset entry */
R_386_TLS_LE_32	=34	;//* 32 bit offset within static TLS block */
R_386_TLS_DTPMOD32 =35	;//* GOT entry containing TLS index */
R_386_TLS_DTPOFF32 =36	;//* GOT entry containing TLS offset */
R_386_TLS_TPOFF32 =37	;//* GOT entry of -ve static TLS offset */

R_386_COUNT	=38	;//* Count of defined relocation types. */

R_PPC_NONE		=0	;//* No relocation. */
R_PPC_ADDR32		=1;
R_PPC_ADDR24		=2;
R_PPC_ADDR16		=3;
R_PPC_ADDR16_LO		=4;
R_PPC_ADDR16_HI		=5;
R_PPC_ADDR16_HA		=6;
R_PPC_ADDR14		=7;
R_PPC_ADDR14_BRTAKEN	=8;
R_PPC_ADDR14_BRNTAKEN	=9;
R_PPC_REL24		=10;
R_PPC_REL14		=11;
R_PPC_REL14_BRTAKEN	=12;
R_PPC_REL14_BRNTAKEN	=13;
R_PPC_GOT16		=14;
R_PPC_GOT16_LO		=15;
R_PPC_GOT16_HI		=16;
R_PPC_GOT16_HA		=17;
R_PPC_PLTREL24		=18;
R_PPC_COPY		=19;
R_PPC_GLOB_DAT		=20;
R_PPC_JMP_SLOT		=21;
R_PPC_RELATIVE		=22;
R_PPC_LOCAL24PC		=23;
R_PPC_UADDR32		=24;
R_PPC_UADDR16		=25;
R_PPC_REL32		=26;
R_PPC_PLT32		=27;
R_PPC_PLTREL32		=28;
R_PPC_PLT16_LO		=29;
R_PPC_PLT16_HI		=30;
R_PPC_PLT16_HA		=31;
R_PPC_SDAREL16		=32;
R_PPC_SECTOFF		=33;
R_PPC_SECTOFF_LO	=34;
R_PPC_SECTOFF_HI	=35;
R_PPC_SECTOFF_HA	=36;

R_PPC_COUNT		=37	;//* Count of defined relocation types. */

R_PPC_TLS		=67;
R_PPC_DTPMOD32		=68;
R_PPC_TPREL16		=69;
R_PPC_TPREL16_LO	=70;
R_PPC_TPREL16_HI	=71;
R_PPC_TPREL16_HA	=72;
R_PPC_TPREL32		=73;
R_PPC_DTPREL16		=74;
R_PPC_DTPREL16_LO	=75;
R_PPC_DTPREL16_HI	=76;
R_PPC_DTPREL16_HA	=77;
R_PPC_DTPREL32		=78;
R_PPC_GOT_TLSGD16	=79;
R_PPC_GOT_TLSGD16_LO	=80;
R_PPC_GOT_TLSGD16_HI	=81;
R_PPC_GOT_TLSGD16_HA	=82;
R_PPC_GOT_TLSLD16	=83;
R_PPC_GOT_TLSLD16_LO	=84;
R_PPC_GOT_TLSLD16_HI	=85;
R_PPC_GOT_TLSLD16_HA	=86;
R_PPC_GOT_TPREL16	=87;
R_PPC_GOT_TPREL16_LO	=88;
R_PPC_GOT_TPREL16_HI	=89;
R_PPC_GOT_TPREL16_HA	=90;

R_PPC_EMB_NADDR32	=101;
R_PPC_EMB_NADDR16	=102;
R_PPC_EMB_NADDR16_LO	=103;
R_PPC_EMB_NADDR16_HI	=104;
R_PPC_EMB_NADDR16_HA	=105;
R_PPC_EMB_SDAI16	=106;
R_PPC_EMB_SDA2I16	=107;
R_PPC_EMB_SDA2REL	=108;
R_PPC_EMB_SDA21		=109;
R_PPC_EMB_MRKREF	=110;
R_PPC_EMB_RELSEC16	=111;
R_PPC_EMB_RELST_LO	=112;
R_PPC_EMB_RELST_HI	=113;
R_PPC_EMB_RELST_HA	=114;
R_PPC_EMB_BIT_FLD	=115;
R_PPC_EMB_RELSDA	=116;


//					/* Count of defined relocation types. */
R_PPC_EMB_COUNT		= (R_PPC_EMB_RELSDA - R_PPC_EMB_NADDR32 + 1);


R_SPARC_NONE		=0;
R_SPARC_8		=1;
R_SPARC_16		=2;
R_SPARC_32		=3;
R_SPARC_DISP8		=4;
R_SPARC_DISP16		=5;
R_SPARC_DISP32		=6;
R_SPARC_WDISP30		=7;
R_SPARC_WDISP22		=8;
R_SPARC_HI22		=9;
R_SPARC_22		=10;
R_SPARC_13		=11;
R_SPARC_LO10		=12;
R_SPARC_GOT10		=13;
R_SPARC_GOT13		=14;
R_SPARC_GOT22		=15;
R_SPARC_PC10		=16;
R_SPARC_PC22		=17;
R_SPARC_WPLT30		=18;
R_SPARC_COPY		=19;
R_SPARC_GLOB_DAT	=20;
R_SPARC_JMP_SLOT	=21;
R_SPARC_RELATIVE	=22;
R_SPARC_UA32		=23;
R_SPARC_PLT32		=24;
R_SPARC_HIPLT22		=25;
R_SPARC_LOPLT10		=26;
R_SPARC_PCPLT32		=27;
R_SPARC_PCPLT22		=28;
R_SPARC_PCPLT10		=29;
R_SPARC_10		=30;
R_SPARC_11		=31;
R_SPARC_64		=32;
R_SPARC_OLO10		=33;
R_SPARC_HH22		=34;
R_SPARC_HM10		=35;
R_SPARC_LM22		=36;
R_SPARC_PC_HH22		=37;
R_SPARC_PC_HM10		=38;
R_SPARC_PC_LM22		=39;
R_SPARC_WDISP16		=40;
R_SPARC_WDISP19		=41;
R_SPARC_GLOB_JMP	=42;
R_SPARC_7		=43;
R_SPARC_5		=44;
R_SPARC_6		=45;
R_SPARC_DISP64		=46;
R_SPARC_PLT64		=47;
R_SPARC_HIX22		=48;
R_SPARC_LOX10		=49;
R_SPARC_H44		=50;
R_SPARC_M44		=51;
R_SPARC_L44		=52;
R_SPARC_REGISTER	=53;
R_SPARC_UA64		=54;
R_SPARC_UA16		=55;


///*
// * Magic number for the elf trampoline, chosen wisely to be an immediate
// * value.
// */
ARM_MAGIC_TRAMP_NUMBER =	$5c000003;


//*
// * Symbol table entries.
// */

type
Elf32_Sym = packed record
	name : Elf32_Word;	//* String table index of name. */
	value : Elf32_Addr;	//* Symbol value. */
	size : Elf32_Word;	//* Size of associated object. */
	info : UCHAR;	//* Type and binding information. */
	other : UCHAR;	//* Reserved (not used). */
	shndx : Elf32_Half;	//* Section index of symbol. */
end;

//* Macros for accessing the fields of st_info. */
//#define ELF32_ST_BIND(info)		((info) >> 4)
//#define ELF32_ST_TYPE(info)		((info) & 0xf)

///* Macro for constructing st_info from field values. */
//#define ELF32_ST_INFO(bind, type)	(((bind) << 4) + ((type) & 0xf))

///* Macro for accessing the fields of st_other. */
//#define ELF32_ST_VISIBILITY(oth)	((oth) & 0x3)

///*
// * ELF definitions common to all 64-bit architectures.
// */

type
Elf64_Addr = uint64;
Elf64_Half = uint16;
Elf64_Off = uint64;
Elf64_Sword = int32;
Elf64_Sxword = int64	;
Elf64_Word = uint32;
Elf64_Xword = uint64;

///*
// * Types of dynamic symbol hash table bucket and chain elements.
// *
// * This is inconsistent among 64 bit architectures, so a machine dependent
// * typedef is required.
// */

//#ifdef __alpha__
//typedef Elf64_Off	Elf64_Hashelt;
//#else
Elf64_Hashelt = Elf64_Word;
//#endif

///* Non-standard class-dependent datatype used for abstraction. */
//typedef Elf64_Xword	Elf64_Size;
//typedef Elf64_Sxword	Elf64_Ssize;

///*
// * ELF header.
// */

Elf64_Ehdr = packed record
	ident : array [0..EI_NIDENT - 1] of UCHAR;	//* File identification. */
	type_ : Elf64_Half;		//* File type. */
	machine : Elf64_Half;	//* Machine architecture. */
	version : Elf64_Word;	//* ELF format version. */
	entry : Elf64_Addr;	//* Entry point. */
	phoff : Elf64_Off;//* Program header file offset. */
	shoff : Elf64_Off;	//* Section header file offset. */
	flags : Elf64_Word;	//* Architecture-specific flags. */
	ehsize : Elf64_Half;	//* Size of ELF header in bytes. */
	phentsize : Elf64_Half;	//* Size of program header entry. */
	phnum : Elf64_Half;	//* Number of program header entries. */
	shentsize : Elf64_Half;	//* Size of section header entry. */
	shnum : Elf64_Half;	//* Number of section header entries. */
	shstrndx : Elf64_Half;	//* Section name strings section. */
end;

///*
// * Section header.
// */


Elf64_Shdr = packed record
	name : Elf64_Word;	//* Section name (index into the
					   //section header string table). */
	type_ : Elf64_Word;	//* Section type. */
	flags : Elf64_Xword;	//* Section flags. */
	addr : Elf64_Addr;	//* Address in memory image. */
	off : Elf64_Off;	//* Offset in file. */
	size : Elf64_Xword;	//* Size in bytes. */
	link : Elf64_Word;	//* Index of a related section. */
	info : Elf64_Word;	//* Depends on section type. */
	addralign : Elf64_Xword;	//* Alignment in bytes. */
	entsize : Elf64_Xword;	//* Size of each entry in section. */
end;

///*
// * Program header.
// */

Elf64_Phdr = packed record
	type_ : Elf64_Word;		//* Entry type. */
	flags : Elf64_Word;	//* Access permission flags. */
	off : Elf64_Off;	//* File offset of contents. */
	vaddr : Elf64_Addr;	//* Virtual address in memory image. */
	paddr : Elf64_Addr;	//* Physical address (not used). */
	filesz : Elf64_Xword;	//* Size of contents in file. */
	memsz : Elf64_Xword;	//* Size of contents in memory. */
	align : Elf64_Xword;	//* Alignment in memory and file. */
end;

///*
// * Dynamic structure.  The ".dynamic" section contains an array of them.
// */

Elf64_Dyn = packed record
	d_tag : Elf64_Sxword;		//* Entry type. */
  case Integer of
    0 : (d_val : Elf64_Xword);
    1 : (d_ptr : Elf64_Addr);

//	union {
//		Elf64_Xword	d_val;	/* Integer value. */
//		Elf64_Addr	d_ptr;	/* Address value. */
//	} d_un;
end;

///*
// * Relocation entries.
// */

//* Relocations that don't need an addend field. */
Elf64_Rel = packed record
	off : Elf64_Addr;	//* Location to be relocated. */
	info : Elf64_Xword;//		/* Relocation type and symbol index. */
end;

//* Relocations that need an addend field. */
Elf64_Rela = packed record
	off : Elf64_Addr;//	/* Location to be relocated. */
	info : Elf64_Xword;//		/* Relocation type and symbol index. */
	addend : Elf64_Sxword;//	/* Addend. */
end;

///* Macros for accessing the fields of r_info. */
//#define ELF64_R_SYM(info)	((info) >> 32)
//#define ELF64_R_TYPE(info)	((info) & 0xffffffffL)

///* Macro for constructing r_info from field values. */
//#define ELF64_R_INFO(sym, type)	((((uint64)(sym)) << 32) + (((uint64)(type)) & 0xffffffffULL))

///*
// * Symbol table entries.
// */

Elf64_Sym = packed record
	name : Elf64_Word;	//* String table index of name. */
	info : UCHAR;	//* Type and binding information. */
	other : UCHAR;	//* Reserved (not used). */
	shndx : Elf64_Half;	//* Section index of symbol. */
	value : Elf64_Addr;	//* Symbol value. */
	size : Elf64_Xword;	//* Size of associated object. */
end;

///* Macros for accessing the fields of st_info. */
//#define ELF64_ST_BIND(info)		((info) >> 4)
//#define ELF64_ST_TYPE(info)		((info) & 0xf)

///* Macro for constructing st_info from field values. */
//#define ELF64_ST_INFO(bind, type)	(((bind) << 4) + ((type) & 0xf))

///* Macro for accessing the fields of st_other. */
//#define ELF64_ST_VISIBILITY(oth)	((oth) & 0x3)

///*
// * Go linker interface
// */
const
ELF64HDRSIZE	= 64;
ELF64PHDRSIZE	=56;
ELF64SHDRSIZE	=64;
ELF64RELSIZE	=16;
ELF64RELASIZE	=24;
ELF64SYMSIZE	=sizeof(Elf64_Sym);

ELF32HDRSIZE	=sizeof(Elf32_Ehdr);
ELF32PHDRSIZE	=sizeof(Elf32_Phdr);
ELF32SHDRSIZE	=sizeof(Elf32_Shdr);
ELF32SYMSIZE	=sizeof(Elf32_Sym) ;
ELF32RELSIZE	=8;




implementation

end.
