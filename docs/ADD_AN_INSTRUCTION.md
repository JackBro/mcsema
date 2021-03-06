# Adding a New Instruction

This section describes how to add a new instruction translation. That is, how to add a mapping from x86 to LLVM for a previously unsupported instruction.

For this example, we will be adding the `FSIN` instruction.

## Which file to change?

First, examine the files in `mc-sema/cfgToLLVM`. It is very likely that the instruction you are translating falls into a category of already translated instructions. If so, select which file to modify. For `FSIN`, we will be modifying `x86Instrs_fpu.cpp`. 

If no existing categories fit your translation (this is very unlikely):
* Use one of the existing files as a template
* Modify `CMakeLists.txt` to build your file
* Modify `InstructionDispatch.cpp` to include your translations in the translation map.

### Boilerplate Code

The process of adding a new instruction starts with some boilerplate code necessary for the translation framework to see a new translation has been defined.

Add the following function in `x86Instrs_fpu.cpp`:

	static InstTransResult doFsin(InstPtr ip, BasicBlock *&b, unsigned reg)
	{
	    return ContinueBlock;
	}

This function will do the actual translation to bitcode. Currently it is empty.

Add a call to the FPU_TRANSLATION macro. This macro will save you writing lots of boilerplate code.

	FPU_TRANSLATION(SIN_F, true, false, true, false, doFsin(ip, block, X86::ST0))

This call indicates the following about the translation: 

* We are translating `SIN_F`
* It will set the last FPU IP register
* It will **not** set the last FPU data register (as it reads from a register). 
* It will set the last FPU opcode register
* It will **not** access memory. 
* The code to do the actual translation will be `doFsin(ip, block, X86::ST0)`.


Add the following statement in `FPU_populateDispatchMap`:

	m[X86::SIN_F] = translate_SIN_F;

The function `translate_SIN_F` will be automatically generated by the `FPU_TRANSLATION` macro.

At this point, build the project to ensure there are no build errors.

## What The Additions Do

Each file has a function named `<functionality>_populateDispatchMap` defined at the very end of the file. This function populates the dispatch map: a mapping of x86 instruction (as defined by LLVM) to a translation function that emits LLVM bitcode. The function prototype for all dispatch functions is:

`InstTransResult <function name>(NativeModulePtr natM, BasicBlock *&block, InstPtr ip, MCInst &inst)`

In this specific exmple, we will be adding to  `FPU_populateDispatchMap` in `x86Instrs_fpu.cpp`.

The x86 instructions as defined by LLVM are not the same as raw x86 opcodes. There is an instruction enum generated by LLVM at build-time, and can be found by looking in `mc-sema/build/llvm-3.2/lib/Target/X86/X86GenInstrInfo.inc`.

Most translations involve similar boilerplate that needs to be present prior to actual translation. Examples of this boilerplate include checking whether or not an instruction will write to memory, determining which floating point flags are modified, whether the last FPU data or last FPU opcode fields are set, and so on. This boilerplate code is encapsulated in macros, in the case of FPU related code the macro is called `FPU_TRANSLATION`.

The `FPU_TRANSLATION` macro is defined as follows:

	FPU_TRANSLATION(NAME, SETPTR, SETDATA, SETFOPCODE, ACCESSMEM, THECALL)

* `NAME`: The x86 instruction being translated, as seen by LLVM. In this case, the instruction is `SIN_F`.
* `SETPTR`: A boolean indicating whether the instruction should set the Last FPU IP register.
* `SETDATA`: A boolean indicating whether the instruction should set the Last FPU data register.
* `SETFOPCODE`: A boolean indicating whether the instruction should set the last FPU opcode register.
* `ACCESSMEM`: A boolean indicating whether this instruction accesses memory. 
* `THECALL`: Code to call to do the raw translation.


### The Translation

Modify the `doFsin` function to the following:

	static InstTransResult doFsin(InstPtr ip, BasicBlock *&b, unsigned reg)
	{
	    Module *M = b->getParent()->getParent();
	
	    Value *regval = FPUR_READ(b, reg);
	
	    // get a declaration for llvm.fsin
	    Type *t = llvm::Type::getX86_FP80Ty(b->getContext());
	    Function *fsin_func = Intrinsic::getDeclaration(M, Intrinsic::sin, t);
	
	    NASSERT(fsin_func != NULL);
	
	    // call llvm.fsin(reg)
	    std::vector<Value*> args;
	    args.push_back(regval);
	
	    Value *fsin_val = CallInst::Create(fsin_func, args, "", b);
	
	    // store return in reg
	    FPUR_WRITE(b, reg, fsin_val);
	
	    return ContinueBlock;
	}

This code will use LLVM's internal sine intrinsic to calculate the sine of a given FPU register. Since `FSIN` only operates on `st0`, this function is always called with `X86::ST0` as the reg argument. It is parametrized in case of future need to take the sine of other registers.


Rebuild the project to ensure everything works, and then move on to the Adding an Instruction Test document.
