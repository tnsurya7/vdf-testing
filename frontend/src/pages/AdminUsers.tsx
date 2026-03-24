import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription,
} from "@/components/ui/dialog";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
import {
  useGetUsersQuery, useCreateUserMutation, useUpdateUserRolesMutation,
  useSetUserEnabledMutation, type UserAccountDto,
} from "@/store/api";
import { toast } from "@/hooks/use-toast";
import { Users, UserPlus, Shield, CheckCheck, XOctagon, ArrowLeft } from "lucide-react";
import AppLayout from "@/components/layout/AppLayout";
import { getSession, clearSession, isAdmin as checkIsAdmin } from "@/lib/authStore";

// ── All role options including Admin ─────────────────────────────────────────
const ALL_ROLE_OPTIONS = [
  { value: "admin",                 label: "Admin" },
  { value: "maker",                 label: "Maker" },
  { value: "checker",               label: "Checker" },
  { value: "convenor",              label: "Convenor" },
  { value: "icvd_committee_member", label: "Committee Member - ICVD" },
  { value: "ccic_committee_member", label: "Committee Member - CCIC" },
] as const;


const roleLabel = (r: string) =>
  ALL_ROLE_OPTIONS.find((o) => o.value === r)?.label ?? r.replace(/_/g, " ");

// Derive sidbi roles from the unified selection (admin is mutually exclusive)
function deriveRoles(selected: string[]): string[] {
  return selected; // just pass through — backend handles admin detection
}

// ── Unified role checklist (Admin + SIDBI roles) ──────────────────────────────
const UnifiedRoleCheckboxGroup = ({
  selected, onChange,
}: { selected: string[]; onChange: (v: string[]) => void }) => (
  <div className="grid grid-cols-2 gap-2">
    {ALL_ROLE_OPTIONS.map((opt) => (
      <div key={opt.value} className="flex items-center gap-2">
        <Checkbox
          id={`role-${opt.value}`}
          checked={selected.includes(opt.value)}
          onCheckedChange={(checked) => {
            if (checked) {
              // Admin is mutually exclusive with all other roles
              if (opt.value === "admin") onChange(["admin"]);
              else onChange([...selected.filter(r => r !== "admin"), opt.value]);
            } else {
              onChange(selected.filter((r) => r !== opt.value));
            }
          }}
        />
        <Label htmlFor={`role-${opt.value}`} className="text-sm cursor-pointer">{opt.label}</Label>
      </div>
    ))}
  </div>
);

type UserFilter = "all" | "active" | "disabled";

// ── Inline status badge ───────────────────────────────────────────────────────
const UserStatusBadge = ({ enabled }: { enabled: boolean }) => (
  <span className={`inline-flex items-center px-2 py-0.5 text-xs font-bold uppercase tracking-wider border ${
    enabled
      ? "bg-green-50 text-green-700 border-green-300"
      : "bg-gray-100 text-gray-500 border-gray-300"
  }`}>
    {enabled ? "Active" : "Disabled"}
  </span>
);

// ── Component ─────────────────────────────────────────────────────────────────
const AdminUsers = () => {
  const navigate = useNavigate();
  const session = getSession();
  const isAdmin = checkIsAdmin(session);

  const { data: users = [], isLoading } = useGetUsersQuery();
  const [createUser, { isLoading: isCreating }] = useCreateUserMutation();
  const [updateRoles] = useUpdateUserRolesMutation();
  const [setEnabled] = useSetUserEnabledMutation();

  // dialogs
  const [addOpen, setAddOpen]   = useState(false);
  const [editUser, setEditUser] = useState<UserAccountDto | null>(null);

  // add-user form state
  const [newEmail, setNewEmail] = useState("");
  const [newRoles, setNewRoles] = useState<string[]>([]);

  // edit-roles state
  const [editRoles, setEditRoles] = useState<string[]>([]);

  // filter
  const [filter, setFilter] = useState<UserFilter>("all");

  const total    = users.length;
  const active   = users.filter((u) => u.enabled).length;
  const disabled = users.filter((u) => !u.enabled).length;

  const filtered = filter === "all" ? users
    : filter === "active" ? users.filter(u => u.enabled)
    : users.filter(u => !u.enabled);

  // ── handlers ────────────────────────────────────────────────────────────
  const handleAddUser = async () => {
    if (!isAdmin) {
      toast({ title: "Access Denied", description: "Only admin users can create accounts.", variant: "destructive" });
      return;
    }
    if (!newEmail.trim()) {
      toast({ title: "Validation Error", description: "Email is required.", variant: "destructive" });
      return;
    }
    if (newRoles.length === 0) {
      toast({ title: "Validation Error", description: "Select at least one role.", variant: "destructive" });
      return;
    }
    const roles = deriveRoles(newRoles);
    try {
      const result = await createUser({
        email: newEmail.trim().toLowerCase(),
        roles,
      }).unwrap();
      toast({ title: "User Created", description: `Password setup email sent to ${result.email}.` });
      setAddOpen(false);
      setNewEmail(""); setNewRoles([]);
    } catch (err: unknown) {
      const status = (err as { status?: number })?.status;
      if (status === 401) {
        toast({ title: "Session Expired", description: "Your session has expired. Please log in again.", variant: "destructive" });
        clearSession();
        window.location.hash = "#/login";
      } else {
        toast({ title: "Error", description: "Could not create user. Email may already exist.", variant: "destructive" });
      }
    }
  };

  const handleEditRoles = async () => {
    if (!isAdmin) {
      toast({ title: "Access Denied", description: "Only admin users can update roles.", variant: "destructive" });
      return;
    }
    if (!editUser || editRoles.length === 0) {
      toast({ title: "Validation Error", description: "Select at least one role.", variant: "destructive" });
      return;
    }
    const roles = deriveRoles(editRoles);
    try {
      await updateRoles({ id: editUser.id, roles }).unwrap();
      toast({ title: "User Updated", description: `Updated ${editUser.email}.` });
      setEditUser(null);
    } catch (err: unknown) {
      const status = (err as { status?: number })?.status;
      if (status === 401) {
        toast({ title: "Session Expired", description: "Please log in again as admin.", variant: "destructive" });
      } else {
        toast({ title: "Error", description: "Could not update user.", variant: "destructive" });
      }
    }
  };

  const handleToggleEnabled = async (user: UserAccountDto) => {
    if (!isAdmin) {
      toast({ title: "Access Denied", description: "Only admin users can enable/disable accounts.", variant: "destructive" });
      return;
    }
    try {
      await setEnabled({ id: user.id, enabled: !user.enabled }).unwrap();
      toast({
        title: user.enabled ? "User Disabled" : "User Enabled",
        description: `${user.email} has been ${user.enabled ? "disabled" : "enabled"}.`,
      });
    } catch (err: unknown) {
      const status = (err as { status?: number })?.status;
      if (status === 401) {
        toast({ title: "Session Expired", description: "Please log in again as admin.", variant: "destructive" });
      } else {
        toast({ title: "Error", description: "Could not update user status.", variant: "destructive" });
      }
    }
  };

  return (
    <AppLayout title="Venture Debt Fund" subtitle="User Management" noPadding
      headerChildren={
        <span className="gov-badge bg-secondary/10 text-secondary border-secondary">
          <Shield className="h-3 w-3 mr-1" /> Admin
        </span>
      }
    >
      <div className="flex-1">
        <main className="p-6 space-y-6">

          {/* Header */}
          <div className="gov-section-header flex items-center justify-between">
            <div>
              <h1 className="text-xl font-bold text-foreground uppercase tracking-wider">Platform Users</h1>
              <p className="text-sm text-muted-foreground mt-1">View all user accounts registered and active on the platform.</p>
            </div>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" className="font-bold uppercase tracking-wider text-xs" onClick={() => navigate("/admin/registrations")}>
                <ArrowLeft className="h-3.5 w-3.5 mr-1.5" /> Back to Registrations
              </Button>
              {isAdmin && (
                <Button size="sm" className="font-bold uppercase tracking-wider text-xs" onClick={() => setAddOpen(true)}>
                  <UserPlus className="h-3.5 w-3.5 mr-1.5" /> Add User
                </Button>
              )}            </div>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-3 gap-4">
            {[
              { label: "TOTAL USERS",    value: total,    icon: Users,      key: "all"      as UserFilter, className: "border-l-4 border-primary" },
              { label: "ACTIVE USERS",   value: active,   icon: CheckCheck, key: "active"   as UserFilter, className: "border-l-4 border-success" },
              { label: "DISABLED USERS", value: disabled, icon: XOctagon,   key: "disabled" as UserFilter, className: "border-l-4 border-destructive" },
            ].map(({ label, value, icon: Icon, key, className }) => (
              <button
                key={label}
                onClick={() => setFilter(f => f === key ? "all" : key)}
                className={`bg-card border border-border p-5 flex items-center gap-4 text-left w-full transition-all ${className} ${
                  filter === key ? "ring-2 ring-primary ring-offset-1 shadow-md" : "hover:shadow-sm hover:brightness-95"
                }`}
              >
                <Icon className="h-6 w-6 text-muted-foreground shrink-0" />
                <div>
                  <p className="text-2xl font-bold text-foreground">{value}</p>
                  <p className="text-xs text-muted-foreground font-bold uppercase tracking-wider mt-0.5">{label}</p>
                </div>
              </button>
            ))}
          </div>

          {/* Table */}
          <div className="bg-card border border-border">
            <div className="gov-section-header bg-muted px-6 py-3 border-b border-border flex items-center justify-between">
              <div>
                <h2 className="font-bold text-foreground text-sm uppercase tracking-wider">
                  {filter === "all" ? "All Users" : filter === "active" ? "Active Users" : "Disabled Users"}
                </h2>
                <p className="text-xs text-muted-foreground mt-0.5">{filtered.length} user{filtered.length !== 1 ? "s" : ""}</p>
              </div>
              {filter !== "all" && (
                <button onClick={() => setFilter("all")} className="text-xs text-primary font-bold uppercase tracking-wider hover:underline">
                  Clear filter ×
                </button>
              )}
            </div>

            {isLoading ? (
              <div className="py-16 text-center"><p className="text-muted-foreground">Loading…</p></div>
            ) : filtered.length === 0 ? (
              <div className="py-16 text-center">
                <Users className="h-10 w-10 text-muted-foreground mx-auto mb-3" />
                <p className="text-foreground font-semibold">No {filter !== "all" ? filter : ""} users</p>
              </div>
            ) : (
              <Table className="gov-table">
                <TableHeader>
                  <TableRow>
                    <TableHead>EMAIL</TableHead>
                    <TableHead>ROLES</TableHead>
                    <TableHead>STATUS</TableHead>
                    {isAdmin && <TableHead className="text-right">ACTIONS</TableHead>}
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filtered.map((user) => (
                    <TableRow key={user.id}>
                      <TableCell className="font-medium text-sm">{user.email}</TableCell>
                      <TableCell className="text-xs">
                        {user.roles.length > 0
                          ? user.roles.map(roleLabel).join(", ")
                          : <span className="text-muted-foreground">—</span>}
                      </TableCell>
                      <TableCell>
                        <UserStatusBadge enabled={user.enabled} />
                      </TableCell>
                      {isAdmin && (
                        <TableCell className="text-right">
                          <div className="flex items-center justify-end gap-1">
                            <Button variant="outline" size="sm" className="h-7 text-xs font-bold uppercase"
                              onClick={() => { setEditUser(user); setEditRoles([...user.roles]); }}>
                              Edit Roles
                            </Button>
                            <Button
                              variant={user.enabled ? "destructive" : "outline"}
                              size="sm"
                              className="h-7 text-xs font-bold uppercase"
                              onClick={() => handleToggleEnabled(user)}
                            >
                              {user.enabled ? "Disable" : "Enable"}
                            </Button>
                          </div>
                        </TableCell>
                      )}
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </div>
        </main>
      </div>

      {/* ── Add User Dialog ─────────────────────────────────────────────────── */}
      <Dialog open={addOpen} onOpenChange={setAddOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="text-lg font-bold uppercase tracking-wide">Add User</DialogTitle>
            <DialogDescription>Create a new platform user. A password setup email will be sent.</DialogDescription>
          </DialogHeader>
          <div className="space-y-4 text-sm">
            <div className="space-y-1.5">
              <Label className="text-xs font-semibold uppercase tracking-wide">Email <span className="text-destructive">*</span></Label>
              <Input placeholder="user@sidbi.in" value={newEmail} onChange={(e) => setNewEmail(e.target.value)} className="h-9" />
            </div>
            <div className="space-y-2">
              <Label className="text-xs font-semibold uppercase tracking-wide">Role <span className="text-destructive">*</span></Label>
              <UnifiedRoleCheckboxGroup selected={newRoles} onChange={setNewRoles} />
            </div>
            <div className="flex gap-3 pt-2">
              <Button variant="outline" className="flex-1 font-bold uppercase tracking-wider" onClick={() => { setAddOpen(false); setNewEmail(""); setNewRoles([]); }}>Cancel</Button>
              <Button className="flex-1 font-bold uppercase tracking-wider" onClick={handleAddUser} disabled={isCreating}>
                {isCreating ? "Creating…" : "Create User"}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* ── Edit Roles Dialog ───────────────────────────────────────────────── */}
      <Dialog open={!!editUser} onOpenChange={() => setEditUser(null)}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="text-lg font-bold uppercase tracking-wide">Edit User</DialogTitle>
            <DialogDescription>{editUser?.email}</DialogDescription>
          </DialogHeader>
          <div className="space-y-4 text-sm">
            <div className="space-y-2">
              <Label className="text-xs font-semibold uppercase tracking-wide">Role <span className="text-destructive">*</span></Label>
              <UnifiedRoleCheckboxGroup selected={editRoles} onChange={setEditRoles} />
            </div>
            <div className="flex gap-3 pt-2">
              <Button variant="outline" className="flex-1 font-bold uppercase tracking-wider" onClick={() => setEditUser(null)}>Cancel</Button>
              <Button className="flex-1 font-bold uppercase tracking-wider" onClick={handleEditRoles}>Save</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </AppLayout>
  );
};

export default AdminUsers;
