(* virt-v2v
 * Copyright (C) 2020 Red Hat Inc.
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

(** This module implements helper functions based on libosinfo. *)

val get_os_by_short_id : string -> Libosinfo.osinfo_os option
(** [get_os_by_short_id short-id] get the [Libosinfo.osinfo_os]
    that has the specified [short-id].
    Returns [None] if there is no matching short ID.
 *)

val string_of_osinfo_device_list : Libosinfo.osinfo_device list -> string
(** Convert an [osinfo_device] list to a printable string for debugging. *)

val os_devices_supports_vio10 : Libosinfo.osinfo_device list -> bool
(** Check [osinfo_device] list includes evidence of virtio-1.0. *)

val os_devices_supports_q35 : Libosinfo.osinfo_device list -> bool
(** Check [osinfo_device] list includes q35. *)
