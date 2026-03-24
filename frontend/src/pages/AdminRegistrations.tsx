import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription,
} from "@/components/ui/dialog";
import { useGetRegistrationsQuery, useUpdateRegistrationStatusMutation, useToggleRegistrationEnabledMutation } from "@/store/api";
import type { Registration } from "@/lib/registrationStore";
import { CheckCircle, XCircle, Eye, Users, Clock, CheckCheck, XOctagon, LayoutDashboard, Settings, Shield, UserMinus } from "lucide-react";
import { toast } from "@/hooks/use-toast";
import { Link, useNavigate } from "react-router-dom";
import AppLayout from "@/components/layout/AppLayout";
import GovStatusBadge from "@/components/GovStatusBadge";

type RegFilter = "all" | "pending" | "approved" | "rejected" | "disabled";

const AdminRegistrations = () => {
  const navigate = useNavigate();
  const { data: registrations = [], isLoading } = useGetRegistrationsQuery();
  const [updateStatus] = useUpdateRegistrationStatusMutation();
  const [toggleEnabled] = useToggleRegistrationEnabledMutation();
  const [selected, setSelected] = useState<Registration | null>(null);
  const [filter, setFilter] = useState<RegFilter>("all");

  const handleAction = async (id: string, status: "approved" | "rejected") => {
    await updateStatus({ id, status });
    setSelected(null);
    toast({ title: `Registration ${status === "approved" ? "Approved" : "Rejected"}`, description: `The registration has been ${status}.` });
  };

  const handleToggle = async (reg: Registration) => {
    try {
      await toggleEnabled(reg.id).unwrap();
      toast({ title: "Account Updated", description: `User account has been ${(reg.accountEnabled ?? reg.enabled) ? "disabled" : "enabled"}.` });
    } catch {
      toast({ title: "Error", description: "Failed to update account status.", variant: "destructive" });
    }
  };

  const pending = registrations.filter(r => r.status === "pending").length;
  const approved = registrations.filter(r => r.status === "approved").length;
  const rejected = registrations.filter(r => r.status === "rejected").length;
  const isDisabled = (r: Registration) => r.status === "approved" && (r.accountEnabled === false || r.enabled === false);
  const disabled = registrations.filter(isDisabled).length;

  const filtered = filter === "disabled"
    ? registrations.filter(isDisabled)
    : filter === "all" ? registrations : registrations.filter(r => r.status === filter);

  return (
    <AppLayout title="SIDBI — Admin Portal" subtitle="Registration Management" noPadding
      headerChildren={
        <span className="gov-badge bg-secondary/10 text-secondary border-secondary">
          <Shield className="h-3 w-3 mr-1" /> Admin
        </span>
      }
    >
      <div className="flex-1">
        <main className="p-6 space-y-6">
          <div className="gov-section-header flex items-center justify-between">
            <div>
              <h1 className="text-xl font-bold text-foreground uppercase tracking-wider">Registration Management</h1>
              <p className="text-sm text-muted-foreground mt-1">Review and approve enterprise registrations for the SIDBI portal.</p>
            </div>
            <Button variant="outline" size="sm" className="font-bold uppercase tracking-wider text-xs" onClick={() => navigate("/admin/users")}>
              <Users className="h-3.5 w-3.5 mr-1.5" /> View User Accounts
            </Button>
          </div>

          <div className="grid grid-cols-2 lg:grid-cols-5 gap-4">
            {[
              { label: "TOTAL",    value: registrations.length, icon: Users,     key: "all"      as RegFilter, className: "border-l-4 border-primary" },
              { label: "PENDING",  value: pending,              icon: Clock,     key: "pending"  as RegFilter, className: "border-l-4 border-warning" },
              { label: "APPROVED", value: approved,             icon: CheckCheck,key: "approved" as RegFilter, className: "border-l-4 border-success" },
              { label: "REJECTED", value: rejected,             icon: XOctagon,  key: "rejected" as RegFilter, className: "border-l-4 border-destructive" },
              { label: "DISABLED", value: disabled,             icon: UserMinus, key: "disabled" as RegFilter, className: "border-l-4 border-muted-foreground" },
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

          <div className="bg-card border border-border">
            <div className="gov-section-header bg-muted px-6 py-3 border-b border-border flex items-center justify-between">
              <div>
                <h2 className="font-bold text-foreground text-sm uppercase tracking-wider">
                  {filter === "all" ? "All Registrations" : `${filter.charAt(0).toUpperCase() + filter.slice(1)} Registrations`}
                </h2>
                <p className="text-xs text-muted-foreground mt-0.5">{filtered.length} record{filtered.length !== 1 ? "s" : ""}</p>
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
                <p className="text-foreground font-semibold">No {filter !== "all" ? filter : ""} registrations</p>
              </div>
            ) : (
              <Table className="gov-table">
                <TableHeader>
                  <TableRow>
                    <TableHead>APPLICANT</TableHead>
                    <TableHead>EMAIL</TableHead>
                    <TableHead>PAN</TableHead>
                    <TableHead>MSME</TableHead>
                    <TableHead>SUBMITTED</TableHead>
                    <TableHead>STATUS</TableHead>
                    <TableHead className="text-right">ACTIONS</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filtered.map((reg) => (
                    <TableRow key={reg.id}>
                      <TableCell className="font-medium">{reg.nameOfApplicant}</TableCell>
                      <TableCell className="text-sm">{reg.email}</TableCell>
                      <TableCell className="font-mono text-sm">{reg.panNo}</TableCell>
                      <TableCell className="uppercase text-sm">{reg.msmeStatus}</TableCell>
                      <TableCell className="text-sm">{new Date(reg.submittedAt).toLocaleDateString()}</TableCell>
                      <TableCell>
                        <div className="flex flex-col gap-1">
                          <GovStatusBadge status={reg.status} />
                          {reg.status === "approved" && (
                            <span className={`gov-badge ${isDisabled(reg) ? "bg-destructive/10 text-destructive border-destructive" : "bg-success/10 text-success border-success"}`}>
                              {isDisabled(reg) ? "DISABLED" : "ACTIVE"}
                            </span>
                          )}
                        </div>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-1">
                          <Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-primary" onClick={() => setSelected(reg)} title="View details">
                            <Eye className="h-4 w-4" />
                          </Button>
                          {reg.status === "approved" && (
                            <Button
                              variant={isDisabled(reg) ? "outline" : "destructive"}
                              size="sm"
                              className="h-7 text-xs font-bold uppercase"
                              onClick={() => handleToggle(reg)}
                            >
                              {isDisabled(reg) ? "Enable" : "Disable"}
                            </Button>
                          )}
                          {reg.status === "pending" && (
                            <>
                              <Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-success" onClick={() => handleAction(reg.id, "approved")} title="Approve">
                                <CheckCircle className="h-4 w-4" />
                              </Button>
                              <Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-destructive" onClick={() => handleAction(reg.id, "rejected")} title="Reject">
                                <XCircle className="h-4 w-4" />
                              </Button>
                            </>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </div>
        </main>
      </div>

      <Dialog open={!!selected} onOpenChange={() => setSelected(null)}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle className="text-lg font-bold uppercase tracking-wide">Application Details</DialogTitle>
            <DialogDescription>Review the full registration information below.</DialogDescription>
          </DialogHeader>
          {selected && (
            <div className="space-y-0 text-sm">
              {[
                ["Email", selected.email],
                ["Applicant", selected.nameOfApplicant],
                ["Registered Office", selected.registeredOffice],
                ["Facilities Location", selected.locationOfFacilities],
                ["Date of Incorporation", new Date(selected.dateOfIncorporation).toLocaleDateString()],
                ["Date of Commencement", new Date(selected.dateOfCommencement).toLocaleDateString()],
                ["PAN No.", selected.panNo],
                ["GST No.", selected.gstNo],
                ["MSME Status", selected.msmeStatus],
                ["Submitted", new Date(selected.submittedAt).toLocaleString()],
              ].map(([label, value]) => (
                <div key={label} className="flex gap-2 py-2.5 border-b border-border last:border-0">
                  <span className="w-44 shrink-0 text-muted-foreground font-semibold text-xs uppercase tracking-wide">{label}</span>
                  <span className="text-foreground capitalize break-all">{value}</span>
                </div>
              ))}
              <div className="flex gap-2 py-2.5 border-b border-border">
                <span className="w-44 shrink-0 text-muted-foreground font-semibold text-xs uppercase tracking-wide">Status</span>
                <GovStatusBadge status={selected.status} />
              </div>
              {selected.status === "pending" && (
                <div className="flex gap-3 pt-5">
                  <Button className="flex-1 bg-success hover:bg-success/90 text-success-foreground font-bold uppercase tracking-wider" onClick={() => handleAction(selected.id, "approved")}>
                    <CheckCircle className="mr-2 h-4 w-4" /> Approve
                  </Button>
                  <Button variant="destructive" className="flex-1 font-bold uppercase tracking-wider" onClick={() => handleAction(selected.id, "rejected")}>
                    <XCircle className="mr-2 h-4 w-4" /> Reject
                  </Button>
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </AppLayout>
  );
};

export default AdminRegistrations;
