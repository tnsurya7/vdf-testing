import { useState } from "react";
import { useNavigate, useParams, useSearchParams } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import { Sheet, SheetContent, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import {
  useGetApplicationByIdQuery,
  useApplyWorkflowActionMutation,
  useGetUsersQuery,
} from "@/store/api";
import type { WorkflowAction } from "@/lib/applicationStore";
import { COMMITTEE_MEMBERS_POOL } from "@/lib/meetingStore";
import { getSession } from "@/lib/authStore";
import { toast } from "@/hooks/use-toast";
import DetailedDataView from "@/components/detailed-app/DetailedDataView";
import GovStatusBadge from "@/components/GovStatusBadge";
import AppLayout from "@/components/layout/AppLayout";
import { prelimViewFields } from "@/lib/prelimConfig";
import StageComments from "@/components/review/StageComments";
import { PanelRightOpen, FileText, Download, Eye as EyeIcon } from "lucide-react";

const GovSectionHeader = ({ title }: { title: string }) => (
  <div className="gov-section-header bg-muted px-6 py-3 border-b border-border">
    <h2 className="font-bold text-foreground text-sm uppercase tracking-widest">{title}</h2>
  </div>
);

const SidbiApplicationReview = () => {
  const { id } = useParams<{ id: string }>();
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const backUrl = searchParams.get("back") || "/sidbi/dashboard";
  const backLabel = backUrl.includes("/meeting/") ? "Back to IC-VD Meeting" : "Back to Dashboard";
  const session = getSession();
  const sidbiRole = session?.sidbiRole ?? "maker";

  const { data: app, isLoading } = useGetApplicationByIdQuery(id!, { skip: !id || !session || (session.roles?.length === 0) });
  const [applyAction, { isLoading: isApplying }] = useApplyWorkflowActionMutation();
  const { data: allUsers = [] } = useGetUsersQuery();

  // Derive real user lists from DB
  const makers = allUsers.filter(u => u.roles.includes("maker"));
  const checkers = allUsers.filter(u => u.roles.includes("checker"));
  const convenors = allUsers.filter(u => u.roles.includes("convenor"));

  const [comment, setComment] = useState("");
  const [commentError, setCommentError] = useState(false);
  const [actionsDrawerOpen, setActionsDrawerOpen] = useState(false);
  const [selectedChecker, setSelectedChecker] = useState("");
  const [selectedMaker, setSelectedMaker] = useState("");
  const [assignTo, setAssignTo] = useState<"checker" | "maker">("checker");
  const [selectedConvenor, setSelectedConvenor] = useState("");
  const [selectedApprover, setSelectedApprover] = useState("");
  const [ccicMemoFile, setCcicMemoFile] = useState<File | null>(null);

  // Set initial comment from app data
  useState(() => {
    if (app?.comments?.["_global"]?.comment && !comment) {
      setComment(app.comments["_global"].comment);
    }
  });

  if (isLoading) {
    return (
      <AppLayout title="Venture Debt Fund" subtitle={`Role: ${sidbiRole}`} backTo={backUrl} backLabel={backLabel}>
        <div className="flex-1 flex items-center justify-center py-20">
          <p className="text-muted-foreground">Loading application…</p>
        </div>
      </AppLayout>
    );
  }

  if (!app) {
    return <main className="min-h-screen flex items-center justify-center"><p className="text-muted-foreground">Application not found.</p></main>;
  }

  const workflowStep = app.workflowStep ?? "prelim_submitted";

  const hasActions = (() => {
    const step = workflowStep;
    const role = sidbiRole;
    if ((step === "prelim_review" || step === "prelim_submitted") && (role === "maker" || role === "checker")) return true;
    if (step === "detailed_maker_review" && role === "maker") return true;
    if (step === "detailed_checker_review" && role === "checker") return true;
    if ((step === "icvd_maker_review" || step === "icvd_note_preparation") && role === "maker") return true;
    if (step === "icvd_checker_review" && role === "checker") return true;
    if (step === "icvd_committee_review" && (role === "convenor" || role === "committee_member")) return true;
    if ((step === "ccic_maker_refine" || step === "ccic_note_preparation") && role === "maker") return true;
    if (step === "ccic_checker_review" && role === "checker") return true;
    if (step === "ccic_committee_review" && (role === "convenor" || role === "committee_member")) return true;
    if (step === "ccic_maker_sanction" && role === "maker") return true;
    if (step === "final_approval" && role === "approving_authority") return true;
    return false;
  })();

  const data = app.prelimData || {};

  const validateComment = () => {
    if (!comment.trim()) {
      setCommentError(true);
      toast({ title: "Comment Required", description: "Please provide a comment before proceeding.", variant: "destructive" });
      return false;
    }
    setCommentError(false);
    return true;
  };

  const doAction = async (action: WorkflowAction, toastTitle: string, extra?: {
    assignedChecker?: string; assignedConvenor?: string; assignedApprover?: string;
    recommendedOutcome?: "rejection" | "pursual";
  }) => {
    if (!id || !validateComment()) return;
    const result = await applyAction({
      id,
      action,
      actor: { role: sidbiRole, id: session?.email ?? "unknown" },
      comment,
      ...extra,
    }).unwrap();

    if (!result.success) {
      toast({ title: "Error", description: result.error, variant: "destructive" });
      return;
    }

    toast({ title: toastTitle });
    navigate("/sidbi/dashboard");
  };

  const renderValue = (key: string) => {
    const val = data[key];
    if (typeof val === "boolean") return val ? "Yes" : "No";
    return val || "—";
  };

  const renderActions = () => {
    const step = workflowStep;
    const role = sidbiRole;

    if ((step === "prelim_review" || step === "prelim_submitted") && (role === "maker" || role === "checker")) {
      return (
        <div className="flex flex-wrap gap-3">
          <Button variant="outline" className="border-warning text-warning hover:bg-warning/10 font-bold uppercase tracking-wider text-xs" disabled={isApplying}
            onClick={() => doAction("revert_prelim", "Reverted to Applicant")}>Revert</Button>
          <Button variant="destructive" className="font-bold uppercase tracking-wider text-xs" disabled={isApplying}
            onClick={() => doAction("reject_prelim", "Rejected")}>Reject</Button>
          <Button className="font-bold uppercase tracking-wider text-xs bg-success hover:bg-success/90" disabled={isApplying}
            onClick={() => doAction("approve_prelim", "Approved — Detailed form open")}>Approve</Button>
        </div>
      );
    }

    if (step === "detailed_maker_review" && role === "maker") {
      const assigneeList = assignTo === "checker" ? checkers : makers;
      const selectedAssignee = assignTo === "checker" ? selectedChecker : selectedMaker;
      const setSelectedAssignee = assignTo === "checker" ? setSelectedChecker : setSelectedMaker;
      const forwardLabel = assignTo === "checker" ? "Forward to Checker" : "Forward to Maker";

      return (
        <>
          <div className="space-y-2 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Assign To</Label>
            <div className="flex gap-4">
              <label className="flex items-center gap-2 cursor-pointer text-sm">
                <input type="radio" name="assignTo" checked={assignTo === "checker"} onChange={() => { setAssignTo("checker"); setSelectedMaker(""); }} className="accent-primary" />
                Checker
              </label>
              <label className="flex items-center gap-2 cursor-pointer text-sm">
                <input type="radio" name="assignTo" checked={assignTo === "maker"} onChange={() => { setAssignTo("maker"); setSelectedChecker(""); }} className="accent-primary" />
                Maker
              </label>
            </div>
          </div>
          <div className="space-y-2 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">
              {assignTo === "checker" ? "Assign Checker" : "Assign Maker"}
            </Label>
            <Select value={selectedAssignee} onValueChange={setSelectedAssignee}>
              <SelectTrigger><SelectValue placeholder={`Select ${assignTo}…`} /></SelectTrigger>
              <SelectContent>
                {assigneeList.map(c => <SelectItem key={c.id} value={c.email}>{c.email}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-3 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Upload Supporting Documents</Label>
            <p className="text-xs text-muted-foreground">Please upload the following documents as applicable:</p>
            <ul className="text-xs text-muted-foreground list-disc list-inside space-y-1 ml-1">
              <li>Partner IM Appraisal</li>
              <li>Pitch Deck</li>
              <li>Cashflow Projections</li>
              <li>MIS</li>
            </ul>
            <input type="file" multiple accept=".pdf,.doc,.docx,.xls,.xlsx,.csv,.jpg,.jpeg,.png"
              className="block w-full text-sm text-foreground file:mr-3 file:py-1.5 file:px-3 file:border file:border-border file:rounded file:bg-muted file:text-muted-foreground file:text-xs file:font-semibold file:uppercase file:tracking-wider hover:file:bg-accent cursor-pointer" />
            <p className="text-xs text-muted-foreground">PDF, Word, Excel, CSV, or Image (max 25MB each)</p>
          </div>
          <div className="space-y-2 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Upload IC-VD Note</Label>
            <input type="file" accept=".pdf,.doc,.docx,.xls,.xlsx,.csv,.jpg,.jpeg,.png"
              className="block w-full text-sm text-foreground file:mr-3 file:py-1.5 file:px-3 file:border file:border-border file:rounded file:bg-muted file:text-muted-foreground file:text-xs file:font-semibold file:uppercase file:tracking-wider hover:file:bg-accent cursor-pointer" />
            <p className="text-xs text-muted-foreground">PDF, Word, Excel, CSV, or Image (max 25MB)</p>
          </div>
          <div className="flex flex-wrap gap-3">
            <Button variant="outline" className="border-warning text-warning hover:bg-warning/10 font-bold uppercase tracking-wider text-xs" disabled={isApplying}
              onClick={() => doAction("revert_detailed", "Reverted to Applicant")}>Revert</Button>
            <Button className="font-bold uppercase tracking-wider text-xs" disabled={isApplying}
              onClick={() => {
                if (!selectedAssignee) { toast({ title: `${assignTo === "checker" ? "Checker" : "Maker"} Required`, description: `Please select a ${assignTo} before forwarding.`, variant: "destructive" }); return; }
                doAction("recommend_pursual", `Forwarded to ${assignTo === "checker" ? "Checker" : "Maker"}`, { assignedChecker: selectedAssignee });
              }}>{forwardLabel}</Button>
          </div>
        </>
      );
    }

    if (step === "detailed_checker_review" && role === "checker") {
      return (
        <>
          <div className="space-y-2 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">IC-VD Note</Label>
            <Button variant="outline" className="w-full font-bold uppercase tracking-wider text-xs" onClick={() => toast({ title: "Download Started", description: "IC-VD Note download initiated." })}>
              Download IC-VD Note
            </Button>
          </div>
          <div className="flex flex-wrap gap-3">
            <Button variant="destructive" className="font-bold uppercase tracking-wider text-xs" disabled={isApplying}
              onClick={() => doAction("reject_final", "Rejected")}>Reject</Button>
            <Button className="font-bold uppercase tracking-wider text-xs" disabled={isApplying}
              onClick={() => doAction("recommend_icvd", "Forwarded to IC-VD")}>Forward IC-VD Note to Convenor</Button>
          </div>
        </>
      );
    }

    if ((step === "icvd_maker_review" || step === "icvd_note_preparation") && role === "maker") {
      return (
        <div className="text-center space-y-2">
          <Button variant="outline" className="w-full font-bold uppercase tracking-wider text-xs" onClick={() => toast({ title: "Download Started", description: "IC-VD Note download initiated." })}>
            Download IC-VD Note
          </Button>
          <p className="text-xs text-muted-foreground">Review and forward the IC-VD Note to Checker.</p>
          <Button onClick={() => doAction("icvd_maker_forward", "IC-VD Note forwarded to Checker")} className="w-full font-bold uppercase tracking-wider text-xs" disabled={isApplying}>
            Forward to Checker
          </Button>
        </div>
      );
    }

    if (step === "icvd_checker_review" && role === "checker") {
      return (
        <>
          <div className="space-y-2 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">IC-VD Note</Label>
            <Button variant="outline" className="w-full font-bold uppercase tracking-wider text-xs" onClick={() => toast({ title: "Download Started" })}>Download IC-VD Note</Button>
          </div>
          <div className="space-y-2 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Assign Convenor</Label>
            <Select value={selectedConvenor} onValueChange={setSelectedConvenor}>
              <SelectTrigger><SelectValue placeholder="Select convenor…" /></SelectTrigger>
              <SelectContent>
                {convenors.map(c => <SelectItem key={c.id} value={c.email}>{c.email}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <Button className="w-full font-bold uppercase tracking-wider text-xs" disabled={isApplying}
            onClick={() => {
              if (!selectedConvenor) { toast({ title: "Convenor Required", variant: "destructive" }); return; }
              doAction("icvd_checker_assign_convenor", "Convenor Assigned — Sent for IC-VD Scheduling", { assignedConvenor: selectedConvenor });
            }}>Assign Convenor & Submit</Button>
        </>
      );
    }

    if ((step === "ccic_maker_refine" || step === "ccic_note_preparation") && role === "maker") {
      return (
        <div className="space-y-4">
          <div className="space-y-2">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Download IC-VD Note</Label>
            <Button variant="outline" className="w-full font-bold uppercase tracking-wider text-xs" onClick={() => toast({ title: "Download Started" })}>
              Download IC-VD Note
            </Button>
          </div>
          <div className="space-y-2">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Upload CCIC-CGM memo <span className="text-destructive">*</span></Label>
            <input
              type="file"
              accept=".pdf,.doc,.docx"
              className="block w-full text-sm text-foreground file:mr-4 file:py-2 file:px-4 file:rounded file:border file:border-border file:text-xs file:font-bold file:uppercase file:tracking-wider file:bg-muted file:text-foreground hover:file:bg-accent cursor-pointer"
              onChange={(e) => setCcicMemoFile(e.target.files?.[0] ?? null)}
            />
            {ccicMemoFile && (
              <p className="text-xs text-muted-foreground">Selected: {ccicMemoFile.name}</p>
            )}
          </div>
          <p className="text-xs text-muted-foreground">Upload the CCIC-CGM memo, then forward to Checker.</p>
          <Button
            onClick={() => doAction("ccic_maker_upload", "CCIC-CGM Note forwarded to Checker")}
            className="w-full font-bold uppercase tracking-wider text-xs"
            disabled={isApplying || !ccicMemoFile}
          >
            Upload & Forward to Checker
          </Button>
        </div>
      );
    }

    if (step === "ccic_checker_review" && role === "checker") {
      return (
        <>
          <div className="space-y-2 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">IC-VD Note</Label>
            <Button variant="outline" className="w-full font-bold uppercase tracking-wider text-xs" onClick={() => toast({ title: "Download Started" })}>Download IC-VD Note</Button>
          </div>
          <div className="space-y-2 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Assign Convenor</Label>
            <Select value={selectedConvenor} onValueChange={setSelectedConvenor}>
              <SelectTrigger><SelectValue placeholder="Select convenor…" /></SelectTrigger>
              <SelectContent>
                {convenors.map(c => <SelectItem key={c.id} value={c.email}>{c.email}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2 mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Assign Approver</Label>
            <Select value={selectedApprover} onValueChange={setSelectedApprover}>
              <SelectTrigger><SelectValue placeholder="Select approver…" /></SelectTrigger>
              <SelectContent>
                {allUsers.filter(u => u.roles.includes("approving_authority")).map(a => <SelectItem key={a.id} value={a.email}>{a.email}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <Button className="w-full font-bold uppercase tracking-wider text-xs" disabled={isApplying}
            onClick={() => {
              if (!selectedConvenor) { toast({ title: "Convenor Required", variant: "destructive" }); return; }
              doAction("ccic_checker_assign_convenor", "Convenor Assigned — Sent for CCIC-CGM Scheduling", {
                assignedConvenor: selectedConvenor,
                assignedApprover: selectedApprover || undefined,
              });
            }}>Assign Convenor & Submit</Button>
        </>
      );
    }

    if (step === "ccic_maker_sanction" && role === "maker") {
      return (
        <div className="space-y-4">
          <div className="space-y-2">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">CCIC-CGM Note</Label>
            <Button variant="outline" className="w-full font-bold uppercase tracking-wider text-xs" onClick={() => toast({ title: "Download Started", description: "CCIC-CGM Note download initiated." })}>
              Download CCIC-CGM Note
            </Button>
          </div>
          <p className="text-xs text-muted-foreground">CCIC-CGM committee has reviewed and consented. Mark this application as sanctioned.</p>
          <Button
            className="w-full font-bold uppercase tracking-wider text-xs bg-success hover:bg-success/90"
            disabled={isApplying}
            onClick={() => doAction("ccic_maker_sanction", "Application Marked as Sanctioned")}
          >
            Mark as Sanctioned
          </Button>
        </div>
      );
    }

    if (step === "final_approval" && role === "approving_authority") {
      return (
        <div className="space-y-2">
          <div className="mb-4">
            <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground mb-2 block">IC-VD Note</Label>
            <Button variant="outline" className="w-full font-bold uppercase tracking-wider text-xs" onClick={() => toast({ title: "Download Started" })}>Download IC-VD Note</Button>
          </div>
          <Button variant="destructive" className="w-full font-bold uppercase tracking-wider text-xs" disabled={isApplying}
            onClick={() => doAction("reject_sanction", "Sanction Rejected")}>Reject Sanction</Button>
          <Button className="w-full font-bold uppercase tracking-wider text-xs bg-success hover:bg-success/90" disabled={isApplying}
            onClick={() => doAction("approve_sanction", "Application Sanctioned")}>Approve Sanction</Button>
        </div>
      );
    }

    return null;
  };

  return (
    <AppLayout
      title="Venture Debt Fund"
      subtitle={`Role: ${sidbiRole}`}
      backTo={backUrl}
      backLabel={backLabel}
      breadcrumbs={[
        { label: backLabel.replace("Back to ", ""), href: backUrl },
        { label: `Review ${app.id.slice(0, 8)}` },
      ]}
      maxWidth="max-w-6xl"
    >
      <div className="mx-auto max-w-6xl">
        <div className="space-y-6">
          <div className="bg-card border border-border p-4 flex items-center justify-between">
            <span className="text-sm font-bold text-foreground">Application ID: <span className="font-mono">{app.id.slice(0, 8)}</span></span>
            <div className="flex items-center gap-2">
              <GovStatusBadge status={workflowStep} stage={app.stage} />
              {hasActions && (
                <Button
                  variant="default"
                  size="sm"
                  className="font-bold uppercase tracking-wider text-xs gap-2"
                  onClick={() => setActionsDrawerOpen(true)}
                >
                  <PanelRightOpen className="h-4 w-4" /> Review Actions
                </Button>
              )}
            </div>
          </div>

            <div className="bg-card border border-border">
              <GovSectionHeader title="Application Details" />
              <div className="p-6 space-y-2 text-sm">
                {[
                  ["Applicant", app.applicantEmail],
                  ["Submitted", new Date(app.submittedAt).toLocaleString()],
                  ["Last Updated", new Date(app.updatedAt).toLocaleString()],
                  ["Workflow Step", workflowStep?.replace(/_/g, " ")?.toUpperCase() ?? "—"],
                ].map(([label, value]) => (
                  <div key={label} className="grid grid-cols-[200px_1fr] gap-2 py-1.5 border-b border-border last:border-0">
                    <span className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">{label}</span>
                    <span className="text-foreground">{value}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="bg-card border border-border">
              <GovSectionHeader title="Preliminary Application Data" />
              <div className="p-6 space-y-0">
                {prelimViewFields.map((field) => (
                  <div key={field.key} className="grid grid-cols-[200px_1fr] gap-2 py-2 border-b border-border last:border-0 text-sm">
                    <span className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">{field.label}</span>
                    <span className="text-foreground">{renderValue(field.key)}</span>
                  </div>
                ))}
              </div>
            </div>

            {app.detailedData && <DetailedDataView data={app.detailedData} />}

            {/* IC-VD Note — visible from icvd stage onwards */}
            {(app.stage === "icvd" || app.stage === "ccic" || app.stage === "final" || app.stage === "post_sanction") && (
              <div className="bg-card border border-border">
                <GovSectionHeader title="IC-VD Note" />
                <div className="p-6 flex items-center gap-3">
                  <FileText className="h-8 w-8 text-primary shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-foreground truncate">IC-VD_Note_{app.id.slice(0, 8)}.pdf</p>
                    <p className="text-xs text-muted-foreground mt-0.5">IC-VD Committee Note Document</p>
                  </div>
                  <div className="flex gap-2 shrink-0">
                    <Button variant="outline" size="sm" className="h-8 text-xs font-bold uppercase tracking-wider gap-1"
                      onClick={() => toast({ title: "Preview", description: "IC-VD Note preview opened." })}>
                      <EyeIcon className="h-3.5 w-3.5" /> Preview
                    </Button>
                    <Button variant="outline" size="sm" className="h-8 text-xs font-bold uppercase tracking-wider gap-1"
                      onClick={() => toast({ title: "Download Started", description: "IC-VD Note download initiated." })}>
                      <Download className="h-3.5 w-3.5" /> Download
                    </Button>
                  </div>
                </div>
              </div>
            )}

            {/* CCIC Note — visible from ccic stage onwards */}
            {(app.stage === "ccic" || app.stage === "final" || app.stage === "post_sanction") && (
              <div className="bg-card border border-border">
                <GovSectionHeader title="CCIC-CGM Note" />
                <div className="p-6 flex items-center gap-3">
                  <FileText className="h-8 w-8 text-primary shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-foreground truncate">CCIC_CGM_Note_{app.id.slice(0, 8)}.pdf</p>
                    <p className="text-xs text-muted-foreground mt-0.5">CCIC-CGM Committee Note Document</p>
                  </div>
                  <div className="flex gap-2 shrink-0">
                    <Button variant="outline" size="sm" className="h-8 text-xs font-bold uppercase tracking-wider gap-1"
                      onClick={() => toast({ title: "Preview", description: "CCIC-CGM Note preview opened." })}>
                      <EyeIcon className="h-3.5 w-3.5" /> Preview
                    </Button>
                    <Button variant="outline" size="sm" className="h-8 text-xs font-bold uppercase tracking-wider gap-1"
                      onClick={() => toast({ title: "Download Started", description: "CCIC-CGM Note download initiated." })}>
                      <Download className="h-3.5 w-3.5" /> Download
                    </Button>
                  </div>
                </div>
              </div>
            )}

            <StageComments auditTrail={app.auditTrail || []} stage={app.stage} />
        </div>

        {hasActions && (
          <Sheet open={actionsDrawerOpen} onOpenChange={setActionsDrawerOpen}>
            <SheetContent side="right" className="w-full sm:max-w-md flex flex-col">
              <SheetHeader className="border-b border-border pb-4">
                <SheetTitle className="text-left font-bold uppercase tracking-wider text-sm">Review Actions</SheetTitle>
              </SheetHeader>
              <div className="flex-1 overflow-y-auto py-6 space-y-4">
                <div>
                  <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground mb-2 block">
                    Comments <span className="text-destructive">*</span>
                  </Label>
                  <Textarea
                    value={comment}
                    onChange={(e) => { setComment(e.target.value); if (e.target.value.trim()) setCommentError(false); }}
                    placeholder="Enter your review comments here…"
                    className={`min-h-[120px] ${commentError ? "border-destructive" : ""}`}
                    maxLength={3000}
                  />
                  {commentError && <p className="text-xs text-destructive mt-1">Comment is required.</p>}
                  <p className="text-xs text-muted-foreground mt-1 text-right">{comment.trim().split(/\s+/).filter(Boolean).length} / 500 words</p>
                </div>
                {renderActions()}
              </div>
            </SheetContent>
          </Sheet>
        )}

        {!hasActions && workflowStep !== "completed" && workflowStep !== "sanctioned" && (
          <div className="mt-6 bg-card border border-border p-6 text-center">
            <p className="text-muted-foreground text-sm">No actions available for your role at this workflow step.</p>
            <div className="text-xs font-mono mt-2 bg-muted p-2 border border-border inline-block">
              <p><span className="font-bold">Role:</span> {sidbiRole} | <span className="font-bold">Step:</span> {workflowStep} | <span className="font-bold">Status:</span> {app.status}</p>
            </div>
          </div>
        )}

        {(workflowStep === "completed" || workflowStep === "sanctioned") && (
          <div className="mt-6 bg-card border border-border p-6 text-center">
            <p className="text-muted-foreground text-sm font-semibold">
              This application has been <span className="uppercase font-bold">{app.status}</span>. No further actions required.
            </p>
          </div>
        )}
      </div>
    </AppLayout>
  );
};

export default SidbiApplicationReview;
