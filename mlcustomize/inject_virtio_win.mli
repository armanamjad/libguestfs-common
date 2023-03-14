(* virt-v2v
 * Copyright (C) 2009-2023 Red Hat Inc.
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

(** Values and functions for installing Windows virtio drivers. *)

type t (** Handle *)

type block_type = Virtio_blk | Virtio_SCSI | IDE
and net_type = Virtio_net | E1000 | RTL8139
and machine_type = I440FX | Q35 | Virt

type virtio_win_installed = {
  block_driver : block_type;
  net_driver : net_type;
  virtio_rng : bool;
  virtio_balloon : bool;
  isa_pvpanic : bool;
  virtio_socket : bool;
  machine : machine_type;
  virtio_1_0 : bool;
}
(** After calling {!install_drivers}, this describes what virtio-win
    drivers we were able to install (and hence, what the guest requires).
    eg. if [virtio_rng] is true then we installed the virtio RNG
    device, otherwise we didn't. *)

val from_path : Guestfs.guestfs -> string -> string -> t
(** Create a new virtio-win handle.  The parameters are [g root path].

    The [path] should point to either the virtio-win ISO
    (eg. F</usr/share/virtio-win/virtio-win.iso>) or the unpacked
    directory (eg. F</usr/share/virtio-win>).

    The libosinfo database is ignored if you use this method. *)

val from_libosinfo : Guestfs.guestfs -> string -> t
(** Create a new virtio-win handle.  The parameters are [g root].

    The libosinfo database will be used as the source for drivers.
    The virtio-win ISO or unpacked directory is ignored if you use
    this method. *)

val from_environment : Guestfs.guestfs -> string -> string -> t
(** Using the [VIRTIO_WIN] environment variable (if present), set up
    the injection handle.

    The parameters are: [g root datadir].  The [datadir] is the path
    from ./configure (eg. {!Config.datadir}).

    This should only be used by [virt-v2v] and is considered a legacy method. *)

val get_block_driver_priority : t -> string list
val set_block_driver_priority : t -> string list -> unit
(** Get or set the current block driver priority list.  This is
    a list of virtio-win block driver names (eg. ["viostor"]) that
    we search until we come to the first [name ^ ".sys"] that
    we find, and that is the block driver which gets installed.

    This module contains a default priority list which should
    be suitable for most use cases. *)

val inject_virtio_win_drivers : t -> Registry.t -> virtio_win_installed
(** [inject_virtio_win_drivers t reg]
    installs virtio drivers from the driver directory or driver
    ISO into the guest driver directory and updates the registry
    so that the [viostor.sys] driver gets loaded by Windows at boot.

    [reg] is the system hive which is open for writes when this
    function is called.

    This returns a {!virtio_win_installed} struct reflecting what devices
    are now required by the guest, either virtio devices if we managed to
    install those, or legacy devices if we didn't. *)

val inject_qemu_ga : t -> bool
(** Inject MSIs (ideally just one) with QEMU Guest Agent into a Windows
    guest.  A firstboot script is also injected which should install
    the MSI(s).

    Returns [true] iff we were able to inject qemu-ga. *)
