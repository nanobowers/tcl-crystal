@[Link("tcl")]
lib LibTcl
  VERSION = "0.0.2"

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

  # pointer for Tcl objects (Tcl_Obj)
  struct Obj
    refCount : LibC::Int
    bytes : LibC::Char*
    length : LibC::Int
    typePtr : Void* # Tcl_ObjType*
    internalRep : Void* # Tcl_ObjInternalRep
  end

  alias Argv = LibC::Char**
  alias ClientData = Void*
  alias FreeProc = (Void* -> Void)

  # Callback for commands created with Tcl_CreateCommand (string-based).
  # The arguments are: client_data, interp, argc, argv
  alias StringCmdProc = (ClientData, Interp*, LibC::Int, Argv -> Result)

  # Callback for commands created with Tcl_CreateObjCommand (object-based).
  # The arguments are: client_data, interp, objc, objv
  alias ObjCmdProc = (ClientData, Interp*, LibC::Int, Obj** -> Result)

  # Callback for when a command is deleted
  alias CmdDeleteProc = (ClientData -> Void)

  # This is but a tiny subset of all available Tcl C functions.
  # see https://www.tcl-lang.org/man/tcl8.6.13/TclLib/contents.htm for details

  # Core Interpreter and Evaluation Functions
  fun evalfile = Tcl_EvalFile(interp : Interp*, fileName : LibC::Char*) : Result
  fun eval = Tcl_Eval(interp : Interp*, script : LibC::Char*) : Result

  fun create_interp = Tcl_CreateInterp : Interp*
  fun delete_interp = Tcl_DeleteInterp(interp : Interp*)

  fun init = Tcl_Init(interp : Interp*) : Result

  # Command Creation (String-based)
  fun create_command = Tcl_CreateCommand(
    interp : Interp*,
    cmdname : LibC::Char*,
    proc : StringCmdProc,
    clientData : Void*,
    deleteProc : CmdDeleteProc*
  )
  
  # Result Handling (String-based)
  fun reset_result = Tcl_ResetResult(interp : Interp*)
  fun get_string_result = Tcl_GetStringResult(interp : Interp*) : LibC::Char*
  fun set_result = Tcl_SetResult(interp : Interp*, result : LibC::Char*, free_proc : FreeProc)

  # Variable Handling (String-based)
  fun set_var = Tcl_SetVar(interp : Interp*, varName : LibC::Char*, newValue : LibC::Char*, flags : VarFlags) : LibC::Char*
  fun set_var2 = Tcl_SetVar2(interp : Interp*, name1 : LibC::Char*, name2 : LibC::Char*, newValue : LibC::Char*, flags : VarFlags) : LibC::Char*
  fun get_var = Tcl_GetVar(interp : Interp*, varName : LibC::Char*, flags : VarFlags) : LibC::Char*
  fun get_var2 = Tcl_GetVar2(interp : Interp*, name1 : LibC::Char*, name2 : LibC::Char*, flags : VarFlags) : LibC::Char*

  # --- Tcl Object API ---
  # Modern Tcl development uses the Object API for better performance and type safety.
  fun eval_objv = Tcl_EvalObjv(interp : Interp*, objc : LibC::Int, objv : Obj**, flags : LibC::Int) : Result

  # Command Creation (Object-based)
  fun create_obj_command = Tcl_CreateObjCommand(interp : Interp*, cmd_name : LibC::Char*, proc : ObjCmdProc, client_data : ClientData, delete_proc : CmdDeleteProc?)

  # Result Handling (Object-based)
  fun get_obj_result = Tcl_GetObjResult(interp : Interp*) : Obj*
  fun set_obj_result = Tcl_SetObjResult(interp : Interp*, result_obj : Obj*)

  # Object Creation and Conversion
  fun new_string_obj = Tcl_NewStringObj(bytes : LibC::Char*, length : LibC::Int) : Obj*
  fun get_string_from_obj = Tcl_GetStringFromObj(obj_ptr : Obj*, length_ptr : LibC::Int*) : LibC::Char*
  fun new_list_obj = Tcl_NewListObj(objc : LibC::Int, objv : Obj**) : Obj*

  # List Object Manipulation
  fun list_obj_append_element = Tcl_ListObjAppendElement(interp : Interp*, list_ptr : Obj*, obj_ptr : Obj*) : Result
  fun list_obj_get_elements = Tcl_ListObjGetElements(interp : Interp*, list_ptr : Obj*, objc_ptr : LibC::Int*, objv_ptr : Obj***) : Result
  fun list_obj_index = Tcl_ListObjIndex(interp : Interp*, list_ptr : Obj*, index : LibC::Int, obj_ptr_ptr : Obj**) : Result
  fun list_obj_length = Tcl_ListObjLength(interp : Interp*, list_ptr : Obj*, length_ptr : LibC::Int*) : Result

  # Reference Counting and Memory Management
  fun preserve = Tcl_Preserve(data : ClientData)
  fun release = Tcl_Release(data : ClientData)

  # # HASH
  fun create_hash_entry = Tcl_CreateHashEntry(table_ptr : Void*, key : LibC::Char*, new_ptr : LibC::Int*) : Void*
  fun delete_hash_entry = Tcl_DeleteHashEntry(entry_ptr : Void*)
  fun delete_hash_table = Tcl_DeleteHashTable(table_ptr : Void*)
  fun find_hash_entry = Tcl_FindHashEntry(table_ptr : Void*, key : LibC::Char*) : Void*
  fun first_hash_entry = Tcl_FirstHashEntry(table_ptr : Void*, search_ptr : Void*) : Void*
  fun get_hash_key = Tcl_GetHashKey(entry_ptr : Void*) : LibC::Char*
  fun get_hash_value = Tcl_GetHashValue(entry_ptr : Void*) : Void*
  fun init_hash_table = Tcl_InitHashTable(table_ptr : Void*, num_keys : LibC::Int)
  fun next_hash_entry = Tcl_NextHashEntry(search_ptr : Void*) : Void*
  fun set_hash_value = Tcl_SetHashValue(entry_ptr : Void*, value : Void*)
  fun eventually_free = Tcl_EventuallyFree(free_proc : FreeProc, client_data : ClientData)

  # # DString
  fun d_string_append = Tcl_DStringAppend(ds_ptr : Void*, bytes : LibC::Char*, length : LibC::Int)
  fun d_string_free = Tcl_DStringFree(ds_ptr : Void*)
  fun d_string_init = Tcl_DStringInit(ds_ptr : Void*)
  fun d_string_length = Tcl_DStringLength(ds_ptr : Void*) : LibC::Int
  fun d_string_truncate = Tcl_DStringTrunc(ds_ptr : Void*, length : LibC::Int)
  fun d_string_value = Tcl_DStringValue(ds_ptr : Void*) : LibC::Char*

  # # REGEXP
  fun reg_exp_compile = Tcl_RegExpCompile(interp : Interp*, pattern : LibC::Char*, length : LibC::Int) : Void*
  fun reg_exp_exec = Tcl_RegExpExec(interp : Interp*, regexp : Void*, text : LibC::Char*, text_len : LibC::Int, start_offset : LibC::Int, nmatches : LibC::Int, pmatches : Void*, eflags : LibC::Int) : LibC::Int
  fun reg_exp_match = Tcl_RegExpMatch(interp : Interp*, text : LibC::Char*, pattern : LibC::Char*) : LibC::Int
  fun reg_exp_range = Tcl_RegExpRange(regexp : Void*, index : LibC::Int, start_ptr : LibC::Char**, end_ptr : LibC::Char**)

end
