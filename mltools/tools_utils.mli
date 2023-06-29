(* Common utilities for OCaml tools in libguestfs.
 * Copyright (C) 2010-2019 Red Hat Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *)

val message : ('a, unit, string, unit) format4 -> 'a
(** Timestamped progress messages.  Used for ordinary messages when
    not [--quiet]. *)

val error : ?exit_code:int -> ('a, unit, string, 'b) format4 -> 'a
(** Standard error function. *)

val warning : ('a, unit, string, unit) format4 -> 'a
(** Standard warning function. *)

val info : ('a, unit, string, unit) format4 -> 'a
(** Standard info function.  Note: Use full sentences for this. *)

val debug : ('a, unit, string, unit) format4 -> 'a
(** Standard debug function.

    The message is only emitted if the verbose ([-v]) flag was set on
    the command line.  As with libguestfs debugging messages, it is
    sent to [stderr]. *)

val open_guestfs : ?identifier:string -> unit -> Guestfs.guestfs
(** Common function to create a new Guestfs handle, with common options
    (e.g. debug, tracing) already set.

    The optional [?identifier] parameter sets the handle identifier. *)

val run_main_and_handle_errors : (unit -> unit) -> unit
(** Common function for handling pretty-printing exceptions. *)

val generated_by : string
(** The string ["generated by <prog> <version>"]. *)

val virt_tools_data_dir : unit -> string
(** Parse the [$VIRT_TOOLS_DATA_DIR] environment variable (used by
    virt-customize and virt-v2v to store auxiliarly tools).  If
    the environment variable is not set, a default value is
    calculated based on configure settings. *)

val parse_size : string -> int64
(** Parse a size field, eg. [10G] *)

val parse_resize : int64 -> string -> int64
(** Parse a size field, eg. [10G], [+20%] etc.  Used particularly by
    [virt-resize --resize] and [--resize-force] options. *)

val human_size : int64 -> string
(** Converts a size in bytes to a human-readable string. *)

type machine_readable_fn = {
  pr : 'a. ('a, unit, string, unit) format4 -> 'a;
} (* [@@unboxed] *)
(** Helper type for {!machine_readable}, used to workaround
    limitations in returned values. *)
val machine_readable : unit -> machine_readable_fn option
(** Returns the printf-like function to use to write all the machine
    readable output to, in case it was enabled via
    [--machine-readable]. *)

type key_store

type cmdline_options = {
  getopt : Getopt.t;              (** The actual {!Getopt} handle. *)
  ks : key_store;                 (** Container for keys read via [--key]. *)
  debug_gc : bool ref;            (** True if [--debug-gc] was used. *)
}
(** Structure representing all the data needed for handling command
    line options. *)

val create_standard_options : Getopt.speclist -> ?anon_fun:Getopt.anon_fun -> ?key_opts:bool -> ?machine_readable:bool -> ?program_name:bool -> Getopt.usage_msg -> cmdline_options
(** Adds the standard libguestfs command line options to the specified ones,
    sorting them, and setting [long_options] to them.

    [key_opts] specifies whether add the standard options related to
    keys management, i.e. [--echo-keys], [--key], and [--keys-from-stdin].
    In case [key_opts] is specified, {!recfield:cmdline_options.ks} will
    contain the keys specified via [--key], so it ought to be passed around
    where needed.

    [machine_readable] specifies whether add the [--machine-readable]
    option.

    [program_name] specifies whether to add the [--program-name] option
    which allows another tool to run this tool and change the program
    name used in error messages.

    Returns a new {!cmdline_options} structure. *)

val external_command : ?echo_cmd:bool -> ?help:string -> string -> string list
(** Run an external command, slurp up the output as a list of lines.

    [echo_cmd] specifies whether to output the full command on verbose
    mode, and it's on by default.

    [help] is an optional string which is printed as a prefix in
    case the external command fails, eg as a hint to the user about
    what we were trying to do. *)

val run_commands : ?echo_cmd:bool -> ?help:string -> (string list * Unix.file_descr option * Unix.file_descr option) list -> int list
(** Run external commands in parallel without using a shell,
    and return a list with their exit codes.

    The list of commands is composed as tuples:
    - the first element is a list of command and its arguments
    - the second element is an optional [Unix.file_descr] descriptor
      for the stdout of the process; if not specified, [stdout] is
      used
    - the third element is an optional [Unix.file_descr] descriptor
      for the stderr of the process; if not specified, [stderr] is
      used

    If any descriptor is specified, it is automatically closed at the
    end of the execution of the command for which it was specified.

    [echo_cmd] specifies whether output the full command on verbose
    mode, and it's on by default.

    [help] is an optional string which is printed as a prefix in
    case the external command fails, eg as a hint to the user about
    what we were trying to do. *)

val run_command : ?echo_cmd:bool -> ?help:string -> ?stdout_fd:Unix.file_descr -> ?stderr_fd:Unix.file_descr -> string list -> int
(** Run an external command without using a shell, and return its exit code.

    If [stdout_fd] or [stderr_fd] is specified, the file descriptor
    is automatically closed after executing the command.

    [echo_cmd] specifies whether output the full command on verbose
    mode, and it's on by default.

    [help] is an optional string which is printed as a prefix in
    case the external command fails, eg as a hint to the user about
    what we were trying to do. *)

val shell_command : ?echo_cmd:bool -> string -> int
(** Run an external shell command, and return its exit code.

    [echo_cmd] specifies whether to output the full command on verbose
    mode, and it's on by default. *)

val uuidgen : unit -> string
(** Run uuidgen to return a random UUID. *)

val rm_rf_only_files : Guestfs.guestfs -> ?filter:(string -> bool) -> string -> unit
(** Using the libguestfs API, recursively remove only files from the
    given directory.  Useful for cleaning [/var/cache] etc in sysprep
    without removing the actual directory structure.  Also if [dir] is
    not a directory or doesn't exist, ignore it.

    The optional [filter] is used to filter out files which will be
    removed: files returning true are not removed.

    XXX Could be faster with a specific API for doing this. *)

val truncate_recursive : Guestfs.guestfs -> string -> unit
(** Using the libguestfs API, recurse into the given directory and
    truncate all files found to zero size. *)

val debug_augeas_errors : Guestfs.guestfs -> unit
(** In verbose mode, any Augeas errors which happened most recently
    on the handle and printed on standard error.  You should usually
    call this just after either [g#aug_init] or [g#aug_load].

    Note this doesn't call {!error} if there were any errors on the
    handle.  It is just for debugging.  It is expected that a
    subsequent Augeas command will fail, eg. when trying to match
    an Augeas path which is expected to exist but does not exist
    because of a parsing error.  In that case turning on debugging
    will reveal the parse error.

    If not in verbose mode, this does nothing. *)

val detect_file_type : string -> [`GZip | `Tar | `XZ | `Zip | `Unknown]
(** Detect type of a file (for a very limited range of file types). *)

val is_partition : string -> bool
(** Return true if the host device [dev] is a partition.  If it's
    anything else, or missing, returns false. *)

val inspect_mount_root : Guestfs.guestfs -> ?mount_opts_fn:(string -> string) -> string -> unit
(** Mounts all the mount points of the specified root, just like
    [guestfish -i] does.

    [mount_opts_fn] represents a function providing the mount options
    for each mount point. *)

val inspect_mount_root_ro : Guestfs.guestfs -> string -> unit
(** Like [inspect_mount_root], but mounting every mount point as
    read-only. *)

val is_btrfs_subvolume : Guestfs.guestfs -> string -> bool
(** Checks if a filesystem is a btrfs subvolume. *)

val key_store_requires_network : key_store -> bool
(** [key_store_requires_network ks] returns [true] iff [ks] contains at least
    one "ID:clevis" selector. *)

val inspect_decrypt : Guestfs.guestfs -> key_store -> unit
(** Simple implementation of decryption: look for any encrypted
    partitions and decrypt them, then rescan for VGs. *)

val with_timeout : string -> int -> ?sleep:int -> (unit -> 'a option) -> 'a
(** [with_timeout op timeout ?sleep fn] implements a timeout loop.

    [fn] is run repeatedly until the function returns [Some result],
    whereupon [with_timeout] returns [result] to the caller.

    If [fn] returns [None] then the we wait a few seconds (controlled
    by [?sleep]) and repeat.

    If the [timeout] (in seconds) is reached, then the function
    calls {!error} and the program exits.  The error message will
    contain the diagnostic string [op] to identify the operation
    which timed out. *)

val run_in_guest_command : Guestfs.guestfs -> string -> ?logfile:string -> ?incompatible_fn:(unit -> unit) -> string -> unit
(** [run_in_guest_command g root ?incompatible_archs_fn cmd]
    runs a command in the guest, which is already mounted for the
    specified [root].  The command is run directly in case the
    architecture of the host and the guest are compatible, optionally
    calling [?incompatible_fn] in case they are not.

    [?logfile] is an optional file in the guest to where redirect
    stdout and stderr of the command. *)
