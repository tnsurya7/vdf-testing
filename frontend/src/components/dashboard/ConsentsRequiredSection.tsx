import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import { useToast } from "@/hooks/use-toast";
import { useAddVoteMutation } from "@/store/api";
import { getSession } from "@/lib/authStore";
import type { CommitteeMeeting as MeetingRecord } from "@/lib/meetingStore";

interface Props {
  meetings: MeetingRecord[];
}

const ConsentsRequiredSection = ({ meetings }: Props) => {
  const { toast } = useToast();
  const session = getSession();
  const [addVote, { isLoading: isVoting }] = useAddVoteMutation();
  const [votingMeetingId, setVotingMeetingId] = useState<string | null>(null);

  const getMyVote = (m: MeetingRecord) => m.votes?.find((v) => v.memberId === session?.email);

  const handleConsent = async (meeting: MeetingRecord, value: "yes" | "no") => {
    if (!session?.email) return;
    setVotingMeetingId(meeting.id);
    try {
      await addVote({
        meetingId: meeting.id,
        vote: {
          memberId: session.email,
          vote: value === "yes" ? "approve" : "reject",
          comment: "",
          timestamp: new Date().toISOString(),
        },
      }).unwrap();
      toast({
        title: "Consent recorded",
        description: `Your consent has been recorded for ${meeting.subject}.`,
      });
    } catch (e) {
      toast({
        title: "Failed to record consent",
        description: e instanceof Error ? e.message : "Please try again.",
        variant: "destructive",
      });
    } finally {
      setVotingMeetingId(null);
    }
  };

  if (meetings.length === 0) {
    return (
      <div className="bg-card border border-border">
        <div className="gov-section-header bg-muted px-6 py-3 border-b border-border">
          <h2 className="font-bold text-foreground text-sm uppercase tracking-wider">Consents Required</h2>
        </div>
        <div className="p-8 text-center">
          <p className="text-sm text-muted-foreground">No consents required at this time.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-card border border-border">
      <div className="gov-section-header bg-muted px-6 py-3 border-b border-border">
        <h2 className="font-bold text-foreground text-sm uppercase tracking-wider">Consents Required</h2>
      </div>
      <Table className="gov-table">
        <TableHeader>
          <TableRow>
            <TableHead>#</TableHead>
            <TableHead>MEETING</TableHead>
            <TableHead>APPLICATIONS</TableHead>
            <TableHead>CONSENT</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {meetings.map((m, i) => {
            const myVote = getMyVote(m);
            const hasVoted = !!myVote;
            const isVoting = votingMeetingId === m.id;
            return (
              <TableRow key={m.id}>
                <TableCell className="font-medium">{i + 1}</TableCell>
                <TableCell className="font-medium">{m.subject}</TableCell>
                <TableCell className="text-sm text-muted-foreground">{m.applicationIds.length} application(s)</TableCell>
                <TableCell>
                  {hasVoted ? (
                    <span className="text-sm font-medium text-success">
                      Consent received — You voted {myVote.vote === "approve" ? "Yes" : "No"}
                    </span>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Button
                        size="sm"
                        variant="outline"
                        className="text-xs font-bold uppercase h-7 px-3"
                        disabled={isVoting}
                        onClick={() => handleConsent(m, "yes")}
                      >
                        Yes
                      </Button>
                      <Button
                        size="sm"
                        variant="destructive"
                        className="text-xs font-bold uppercase h-7 px-3"
                        disabled={isVoting}
                        onClick={() => handleConsent(m, "no")}
                      >
                        No
                      </Button>
                    </div>
                  )}
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </div>
  );
};

export default ConsentsRequiredSection;
