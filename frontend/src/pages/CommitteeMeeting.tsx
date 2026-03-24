import { useEffect, useState, useMemo, useRef } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { format, parse, isValid } from "date-fns";
import { CalendarIcon, Calendar as CalendarLucide } from "lucide-react";
import { DayPicker } from "react-day-picker";
import "react-day-picker/dist/style.css";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import AppLayout from "@/components/layout/AppLayout";
import { cn } from "@/lib/utils";
import { getSession, isSidbi } from "@/lib/authStore";
import { toast } from "@/hooks/use-toast";
import { useGetApplicationsQuery, useApplyWorkflowActionMutation, useCreateMeetingMutation, useGetMeetingsQuery } from "@/store/api";
import type { WorkflowStep } from "@/lib/applicationStore";
import {
  COMMITTEE_MEMBERS_POOL,
  type MeetingType, type CommitteeMember,
} from "@/lib/meetingStore";
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import GovStatusBadge from "@/components/GovStatusBadge";

/** Date field: manual text input (DD/MM/YYYY) + react-day-picker calendar */
const DatePickerField = ({
  value,
  onChange,
}: {
  value: Date | undefined;
  onChange: (d: Date | undefined) => void;
}) => {
  const [textVal, setTextVal] = useState(value ? format(value, "dd/MM/yyyy") : "");
  const [open, setOpen] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const handleTextChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const digits = e.target.value.replace(/\D/g, "");
    let formatted = digits;
    if (digits.length > 2) formatted = digits.slice(0, 2) + "/" + digits.slice(2);
    if (digits.length > 4) formatted = digits.slice(0, 2) + "/" + digits.slice(2, 4) + "/" + digits.slice(4, 8);
    setTextVal(formatted);
    if (formatted.length === 10) {
      const parsed = parse(formatted, "dd/MM/yyyy", new Date());
      if (isValid(parsed)) onChange(parsed);
      else onChange(undefined);
    } else {
      onChange(undefined);
    }
  };

  const handleDaySelect = (d: Date | undefined) => {
    onChange(d);
    setTextVal(d ? format(d, "dd/MM/yyyy") : "");
    setOpen(false);
  };

  return (
    <div className="flex gap-2">
      <Input
        ref={inputRef}
        placeholder="DD/MM/YYYY"
        value={textVal}
        onChange={handleTextChange}
        maxLength={10}
        className="h-10 font-mono tracking-wider w-[140px]"
      />
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button type="button" variant="outline" className={cn("h-10 w-10 p-0 shrink-0", !value && "text-muted-foreground")}>
            <CalendarIcon className="h-4 w-4" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-auto p-0" align="start">
          <DayPicker
            mode="single"
            selected={value}
            onSelect={handleDaySelect}
            defaultMonth={value ?? new Date()}
            captionLayout="dropdown-buttons"
            fromYear={2020}
            toYear={new Date().getFullYear() + 5}
            className="p-3"
          />
        </PopoverContent>
      </Popover>
    </div>
  );
};

const CommitteeMeeting = () => {
  const { type } = useParams<{ type: string }>();
  const navigate = useNavigate();
  const session = getSession();
  const meetingType: MeetingType = type === "ccic" ? "ccic" : "icvd";

  const [date, setDate] = useState<Date>();
  const [time, setTime] = useState("10:00");
  const [selectedApps, setSelectedApps] = useState<string[]>([]);
  const [subject, setSubject] = useState("");
  const [committeeMembers, setCommitteeMembers] = useState("");
  const [approvingAuthority, setApprovingAuthority] = useState("");

  const { data: apps = [], refetch: refetchApps } = useGetApplicationsQuery(
    session?.sidbiRole === "convenor" ? { role: "convenor" } : undefined,
    { skip: !session || !isSidbi(session) || session.sidbiRole !== "convenor" }
  );
  const { data: scheduledMeetings = [], refetch: refetchMeetings } = useGetMeetingsQuery({ type: meetingType });
  const [createMeetingMut] = useCreateMeetingMutation();
  const [applyAction] = useApplyWorkflowActionMutation();

  const isICVD = meetingType === "icvd";
  const title = isICVD ? "IC-VD Committee" : "CCIC-CGM Committee";
  const icvdEligibleSteps: WorkflowStep[] = ["icvd_maker_review", "icvd_checker_review", "icvd_convenor_scheduling", "icvd_committee_review"];
  const ccicEligibleSteps: WorkflowStep[] = ["ccic_maker_refine", "ccic_checker_review", "ccic_convenor_scheduling", "ccic_committee_review"];

  useEffect(() => {
    if (!session || !isSidbi(session) || session.sidbiRole !== "convenor") {
      navigate("/login");
    }
  }, []);

  const eligibleApps = useMemo(() => {
    const steps = isICVD ? icvdEligibleSteps : ccicEligibleSteps;
    return apps.filter((a) => steps.includes(a.workflowStep as WorkflowStep));
  }, [apps, isICVD]);

  const meetingNumber = scheduledMeetings.length + 1;

  const toggleApp = (id: string) => {
    setSelectedApps((prev) =>
      prev.includes(id) ? prev.filter((a) => a !== id) : [...prev, id]
    );
  };

  const handleSchedule = async () => {
    if (!date) { toast({ title: "Date Required", variant: "destructive" }); return; }
    if (selectedApps.length === 0) { toast({ title: "Applications Required", variant: "destructive" }); return; }

    const meeting = await createMeetingMut({
      type: meetingType,
      subject: subject || `${isICVD ? "IC-VD" : "CCIC-CGM"} Meeting #${meetingNumber}`,
      meetingNumber,
      dateTime: `${format(date, "yyyy-MM-dd")}T${time}:00`,
      totalMembers: COMMITTEE_MEMBERS_POOL,
      selectedMembers: COMMITTEE_MEMBERS_POOL,
      makerEmail: "maker@sidbi.com",
      checkerEmail: "checker@sidbi.com",
      convenorEmail: session?.email ?? "convenor@sidbi.com",
      approverEmail: isICVD ? undefined : "approving.authority@sidbi.com",
      applicationIds: selectedApps,
      status: "scheduled",
    }).unwrap();

    const action = isICVD ? "icvd_schedule_meeting" : "ccic_schedule_meeting";
    for (const appId of selectedApps) {
      await applyAction({
        id: appId, action: action as any,
        actor: { role: "convenor", id: session?.email ?? "convenor" },
        comment: `Scheduled for ${isICVD ? "IC-VD" : "CCIC-CGM"} Meeting #${meetingNumber} on ${format(date, "dd/MM/yyyy")} at ${time}`,
        meetingId: meeting.id,
      });
    }

    toast({ title: "Meeting Scheduled", description: `${isICVD ? "IC-VD" : "CCIC-CGM"} Meeting #${meetingNumber} scheduled.` });
    setSelectedApps([]); setSubject(""); setDate(undefined); setTime("10:00");
  };

  const GovSectionHeader = ({ title: t }: { title: string }) => (
    <div className="gov-section-header bg-muted px-6 py-3 border-b border-border">
      <h2 className="font-bold text-foreground text-sm uppercase tracking-widest">{t}</h2>
    </div>
  );

  return (
    <AppLayout title="Venture Debt Fund" subtitle="Committee Meeting Scheduling" backTo="/sidbi/dashboard" backLabel="Back to Dashboard"
      breadcrumbs={[{ label: "Dashboard", href: "/sidbi/dashboard" }, { label: `${title} Meeting` }]} maxWidth="max-w-5xl">
      <div className="mx-auto max-w-5xl space-y-6">
        <div className="bg-card border border-border">
          <GovSectionHeader title={`${isICVD ? "IC-VD" : "CCIC-CGM"} Meeting #${meetingNumber}`} />
          <div className="p-6 space-y-4">
            <div className="grid grid-cols-[160px_1fr] gap-4 items-start">
              <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground pt-2">Sub:</Label>
              <Textarea placeholder={`${isICVD ? "IC-VD" : "CCIC-CGM"} Meeting Review #${meetingNumber}`} value={subject} onChange={(e) => setSubject(e.target.value)} className="min-h-[60px] resize-none" />
            </div>
            <div className="grid grid-cols-[160px_1fr] gap-4 items-center">
              <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Team:</Label>
              <Input value="sidbi-maker@demo.com, sidbi-checker@demo.com" readOnly className="bg-muted" />
            </div>
            <div className="grid grid-cols-[160px_1fr] gap-4 items-center">
              <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Committee Members:</Label>
              <Input
                placeholder="Enter committee members (e.g. names, designations)"
                value={committeeMembers}
                onChange={(e) => setCommitteeMembers(e.target.value)}
              />
            </div>
            {!isICVD && (
              <div className="grid grid-cols-[160px_1fr] gap-4 items-center">
                <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Approving Authority:</Label>
                <Input
                  placeholder="Enter approving authority (e.g. name, designation, email)"
                  value={approvingAuthority}
                  onChange={(e) => setApprovingAuthority(e.target.value)}
                />
              </div>
            )}
            <div className="grid grid-cols-[160px_1fr] gap-4 items-center">
              <Label className="font-semibold text-xs uppercase tracking-wide text-muted-foreground">Date & Time:</Label>
              <div className="flex gap-2 items-center">
                <DatePickerField value={date} onChange={setDate} />
                <Input type="time" value={time} onChange={(e) => setTime(e.target.value)} className="w-[130px] h-10" />
              </div>
            </div>
          </div>
        </div>

        <div className="bg-card border border-border">
          <div className="gov-section-header bg-muted px-6 py-3 border-b border-border flex items-center justify-between">
            <h2 className="font-bold text-foreground text-sm uppercase tracking-widest">Applications</h2>
            <div className="flex items-center gap-3">
              <span className="text-xs text-muted-foreground">Forwarded: <span className="font-bold text-foreground">{eligibleApps.length}</span></span>
              <span className="text-xs text-muted-foreground">Selected: <span className="font-bold text-primary">{selectedApps.length}</span></span>
            </div>
          </div>
          <div className="p-6">
            {eligibleApps.length === 0 ? (
              <p className="text-sm text-muted-foreground text-center py-8">No applications awaiting {isICVD ? "IC-VD" : "CCIC-CGM"} committee scheduling.</p>
            ) : (
              <table className="w-full text-sm">
                <thead><tr className="bg-muted border-b border-border">
                  <th className="text-left px-4 py-2 font-bold text-xs uppercase tracking-wide text-muted-foreground w-16">Select</th>
                  <th className="text-left px-4 py-2 font-bold text-xs uppercase tracking-wide text-muted-foreground">Applicants</th>
                </tr></thead>
                <tbody>
                  {eligibleApps.map((app, idx) => (
                    <tr key={app.id} className={cn("border-b border-border cursor-pointer transition-all", idx % 2 === 0 ? "bg-muted/40" : "bg-card", selectedApps.includes(app.id) && "bg-primary/5")} onClick={() => toggleApp(app.id)}>
                      <td className="px-4 py-3"><Checkbox checked={selectedApps.includes(app.id)} /></td>
                      <td className="px-4 py-3">
                        <span className="font-medium text-primary underline cursor-pointer hover:text-primary/80" onClick={(e) => { e.stopPropagation(); navigate(`/sidbi/review/${app.id}?back=/sidbi/meeting/${type}`); }}>
                          Applicant {idx + 1}: IC-VD note
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>

        <div className="flex justify-end">
          <Button onClick={handleSchedule} className="font-bold uppercase tracking-wider text-xs px-8 py-3" disabled={eligibleApps.length === 0}>
            <CalendarLucide className="h-4 w-4 mr-2" /> Schedule Meeting
          </Button>
        </div>
      </div>
    </AppLayout>
  );
};

export default CommitteeMeeting;
