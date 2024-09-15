@[Link("tcl")]
lib LibTcl
  VERSION = "0.0.1"

  enum Result
    Ok       = 0
    Error    = 1
    Return   = 2
    Break    = 3
    Continue = 4
  end

  @[Flags]
  enum VarFlags
    GlobalOnly    = 1
    NamespaceOnly = 2
    AppendValue   = 4
    ListElement   = 8
  end

  struct Interp
    result : LibC::Char*
    freeProc : Void*
    errorLine : LibC::Int
  end

  alias Argv = LibC::Char**
  alias ClientData = Void*
  alias CmdProc = (ClientData, Interp*, LibC::Int, Argv -> Result)
  alias CmdDeleteProc = (Void* -> Void)
  alias FreeProc = (Void* -> Void)

  # This is but a tiny subset of all available Tcl C functions.
  # see https://www.tcl-lang.org/man/tcl8.6.13/TclLib/contents.htm for details

  fun evalfile = Tcl_EvalFile(interp : Interp*, fileName : LibC::Char*) : Result
  fun eval = Tcl_Eval(interp : Interp*, script : LibC::Char*) : Result

  fun create_interp = Tcl_CreateInterp : Interp*
  fun delete_interp = Tcl_DeleteInterp(interp : Interp)

  fun init = Tcl_Init(interp : Interp*)

  fun create_command = Tcl_CreateCommand(
    interp : Interp*,
    cmdname : LibC::Char*,
    proc : CmdProc,
    clientData : Void*,
    deleteProc : CmdDeleteProc*
  )

  fun reset_result = Tcl_ResetResult(interp : Interp*)
  fun get_string_result = Tcl_GetStringResult(interp : Interp*) : LibC::Char*

  fun set_result = Tcl_SetResult(interp : Interp*, result : LibC::Char*, free_proc : FreeProc)
  fun set_var = Tcl_SetVar(interp : Interp*, varName : LibC::Char*, newValue : LibC::Char*, flags : VarFlags) : LibC::Char*
  fun set_var2 = Tcl_SetVar2(interp : Interp*, name1 : LibC::Char*, name2 : LibC::Char*, newValue : LibC::Char*, flags : VarFlags) : LibC::Char*
  fun get_var = Tcl_GetVar(interp : Interp*, varName : LibC::Char*, flags : VarFlags) : LibC::Char*
  fun get_var2 = Tcl_GetVar2(interp : Interp*, name1 : LibC::Char*, name2 : LibC::Char*, flags : VarFlags) : LibC::Char*

  # Tcl_Preserve
  # Tcl_Release
  # Tcl_EventuallyFree

  # # HASH
  # Tcl_CreateHashEntry
  # Tcl_DeleteHashEntry
  # Tcl_DeleteHashTable
  # Tcl_FindHashEntry
  # Tcl_FirstHashEntry
  # Tcl_GetHashKey
  # Tcl_GetHashValue
  # Tcl_HashEntry
  # Tcl_HashSearch
  # Tcl_HashTable
  # Tcl_InitHashTable
  # Tcl_NextHashEntry
  # Tcl_SetHashValue

  # # DString
  # Tcl_DString
  # Tcl_DStringAppend
  # Tcl_DStringFree
  # Tcl_DStringInit
  # Tcl_DStringLength
  # Tcl_DStringTrunc
  # Tcl_DStringValue

  # # REGEXP
  # Tcl_RegExp
  # Tcl_RegExpCompile
  # Tcl_RegExpExec
  # Tcl_RegExpMatch
  # Tcl_RegExpRange

end
