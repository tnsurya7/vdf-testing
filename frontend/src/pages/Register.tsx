import { useAddRegistrationMutation } from "@/store/api";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { format, parse, isValid } from "date-fns";
import { CalendarIcon, Eye, EyeOff } from "lucide-react";
import { useState, useRef } from "react";
import { DayPicker } from "react-day-picker";
import "react-day-picker/dist/style.css";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Link } from "react-router-dom";
import { toast } from "@/hooks/use-toast";
import PublicLayout from "@/components/layout/PublicLayout";

const registerSchema = z.object({
  email: z.string().email("Please enter a valid email address"),
  phoneNumber: z.string().regex(/^[0-9]{10}$/, "Phone number must be exactly 10 digits"),
  password: z.string().min(8, "Password must be at least 8 characters")
    .regex(/[A-Z]/, "Must contain at least one uppercase letter")
    .regex(/[a-z]/, "Must contain at least one lowercase letter")
    .regex(/[0-9]/, "Must contain at least one number")
    .regex(/[^A-Za-z0-9]/, "Must contain at least one special character"),
  retypePassword: z.string().min(1, "Please retype your password"),
  nameOfApplicant: z.string().min(1, "Name is required").max(250, "Max 250 characters"),
  registeredOffice: z.string().min(1, "Registered office is required").max(250, "Max 250 characters"),
  locationOfFacilities: z.string().min(1, "Location is required").max(250, "Max 250 characters"),
  dateOfIncorporation: z.date({ required_error: "Date of incorporation is required" }),
  dateOfCommencement: z.date({ required_error: "Date of commencement is required" }),
  panNo: z.string().min(1, "PAN is required").regex(/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/, "Invalid PAN format (e.g., ABCDE1234F)"),
  gstNo: z.string().min(1, "GST is required").regex(/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/, "Invalid GST format (e.g., 22ABCDE1234F1Z5)"),
  cin: z.string().min(1, "CIN is required").regex(/^[A-Z]{1}[0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$/, "Invalid CIN format (e.g., U12345AB2019PTC123456)"),
  msmeStatus: z.enum(["micro", "small", "medium"], { required_error: "MSME status is required" }),
}).refine((data) => data.password === data.retypePassword, {
  message: "Passwords do not match",
  path: ["retypePassword"],
});

type RegisterFormValues = z.infer<typeof registerSchema>;

const FieldRow = ({ label, required, children }: { label: string; required?: boolean; children: React.ReactNode }) => (
  <div className="space-y-1.5">
    <FormLabel className="text-foreground font-semibold text-xs uppercase tracking-wide">
      {label} {required && <span className="text-destructive">*</span>}
    </FormLabel>
    {children}
  </div>
);

/** Date field: manual text input (DD/MM/YYYY) + react-day-picker calendar */
const DatePickerField = ({
  value,
  onChange,
  placeholder = "DD/MM/YYYY",
  maxDate,
}: {
  value: Date | undefined;
  onChange: (d: Date | undefined) => void;
  placeholder?: string;
  maxDate?: Date;
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
      if (isValid(parsed) && (!maxDate || parsed <= maxDate)) {
        onChange(parsed);
      } else {
        onChange(undefined);
      }
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
        placeholder={placeholder}
        value={textVal}
        onChange={handleTextChange}
        maxLength={10}
        className="h-10 font-mono tracking-wider flex-1"
      />
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            type="button"
            variant="outline"
            className={cn("h-10 w-10 p-0 shrink-0", !value && "text-muted-foreground")}
          >
            <CalendarIcon className="h-4 w-4" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-auto p-0" align="end">
          <DayPicker
            mode="single"
            selected={value}
            onSelect={handleDaySelect}
            disabled={maxDate ? { after: maxDate } : undefined}
            defaultMonth={value ?? maxDate}
            captionLayout="dropdown-buttons"
            fromYear={1900}
            toYear={new Date().getFullYear()}
            className="p-3"
          />
        </PopoverContent>
      </Popover>
    </div>
  );
};

const Register = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [showRetypePassword, setShowRetypePassword] = useState(false);
  const [addRegistration, { isLoading }] = useAddRegistrationMutation();

  const form = useForm<RegisterFormValues>({
    resolver: zodResolver(registerSchema),
    defaultValues: {
      email: "", phoneNumber: "", password: "", retypePassword: "",
      nameOfApplicant: "", registeredOffice: "", locationOfFacilities: "",
      panNo: "", gstNo: "", cin: "",
    },
  });

  async function onSubmit(data: RegisterFormValues) {
    await addRegistration({
      email: data.email, password: data.password, nameOfApplicant: data.nameOfApplicant,
      registeredOffice: data.registeredOffice, locationOfFacilities: data.locationOfFacilities,
      dateOfIncorporation: data.dateOfIncorporation.toISOString(),
      dateOfCommencement: data.dateOfCommencement.toISOString(),
      panNo: data.panNo, gstNo: data.gstNo, cin: data.cin, msmeStatus: data.msmeStatus,
    });
    toast({ title: "Registration Submitted", description: "Your application has been submitted for admin review." });
    form.reset();
  }

  return (
    <PublicLayout subtitle="Enterprise Registration" backTo="/login" backLabel="Sign In">
      <main className="flex-1 px-4 py-10">
        <div className="mx-auto max-w-2xl">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-foreground uppercase tracking-wide">Create Account</h1>
            <p className="text-sm text-muted-foreground mt-1">Register your enterprise for Venture Debt Fund financing</p>
          </div>

          <div className="bg-card border border-border">
            <div className="gov-section-header bg-muted px-6 py-3 border-b border-border flex items-center justify-between">
              <p className="text-xs font-bold text-foreground uppercase tracking-widest">Account Credentials</p>
            </div>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)}>
                <div className="px-6 py-6 space-y-5">
                  <FormField control={form.control} name="email" render={({ field }) => (
                    <FormItem><FieldRow label="Email ID" required>
                      <FormControl><Input placeholder="you@company.com" className="h-10" {...field} /></FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                  <FormField control={form.control} name="phoneNumber" render={({ field }) => (
                    <FormItem><FieldRow label="Phone Number" required>
                      <FormControl><Input placeholder="10 digit phone number" className="h-10 font-mono tracking-wider" maxLength={10} {...field} onChange={(e) => field.onChange(e.target.value.replace(/\D/g, ""))} /></FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                  <FormField control={form.control} name="password" render={({ field }) => (
                    <FormItem><FieldRow label="Password" required>
                      <FormControl>
                        <div className="relative">
                          <Input type={showPassword ? "text" : "password"} placeholder="Min 8 chars, upper, lower, number, special" className="h-10" {...field} />
                          <Button type="button" variant="ghost" size="icon" className="absolute right-1 top-1/2 -translate-y-1/2 h-8 w-8 text-muted-foreground" onClick={() => setShowPassword(!showPassword)}>
                            {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                          </Button>
                        </div>
                      </FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                  <FormField control={form.control} name="retypePassword" render={({ field }) => (
                    <FormItem><FieldRow label="Retype Password" required>
                      <FormControl>
                        <div className="relative">
                          <Input type={showRetypePassword ? "text" : "password"} placeholder="Re-enter your password" className="h-10" {...field} />
                          <Button type="button" variant="ghost" size="icon" className="absolute right-1 top-1/2 -translate-y-1/2 h-8 w-8 text-muted-foreground" onClick={() => setShowRetypePassword(!showRetypePassword)}>
                            {showRetypePassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                          </Button>
                        </div>
                      </FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                </div>

                <div className="gov-section-header bg-muted px-6 py-3 border-y border-border">
                  <p className="text-xs font-bold text-foreground uppercase tracking-widest">Business Information</p>
                </div>
                <div className="px-6 py-6 space-y-5">
                  <FormField control={form.control} name="nameOfApplicant" render={({ field }) => (
                    <FormItem><FieldRow label="Name of Applicant" required>
                      <FormControl><Input placeholder="Full legal name of the entity" className="h-10" {...field} /></FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                  <FormField control={form.control} name="cin" render={({ field }) => (
                    <FormItem><FieldRow label="CIN No." required>
                      <FormControl><Input placeholder="U12345AB2019PTC123456" className="h-10 font-mono tracking-wider" {...field} onChange={(e) => field.onChange(e.target.value.toUpperCase())} /></FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                  <FormField control={form.control} name="registeredOffice" render={({ field }) => (
                    <FormItem><FieldRow label="Registered Office" required>
                      <FormControl><Input placeholder="Registered office address" className="h-10" {...field} /></FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                  <FormField control={form.control} name="locationOfFacilities" render={({ field }) => (
                    <FormItem><FieldRow label="Location of Facilities" required>
                      <FormControl><Input placeholder="Existing facility locations" className="h-10" {...field} /></FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                  <FormField control={form.control} name="dateOfIncorporation" render={({ field }) => (
                    <FormItem>
                      <FieldRow label="Date of Incorporation" required>
                        <FormControl>
                          <DatePickerField value={field.value} onChange={field.onChange} maxDate={new Date()} />
                        </FormControl>
                        <FormMessage />
                      </FieldRow>
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="dateOfCommencement" render={({ field }) => (
                    <FormItem>
                      <FieldRow label="Date of Commencement" required>
                        <FormControl>
                          <DatePickerField value={field.value} onChange={field.onChange} maxDate={new Date()} />
                        </FormControl>
                        <FormMessage />
                      </FieldRow>
                    </FormItem>
                  )} />
                </div>

                <div className="gov-section-header bg-muted px-6 py-3 border-y border-border">
                  <p className="text-xs font-bold text-foreground uppercase tracking-widest">Compliance & Classification</p>
                </div>
                <div className="px-6 py-6 space-y-5">
                  <FormField control={form.control} name="panNo" render={({ field }) => (
                    <FormItem><FieldRow label="PAN No." required>
                      <FormControl><Input placeholder="ABCDE1234F" className="h-10 font-mono tracking-wider" {...field} onChange={(e) => field.onChange(e.target.value.toUpperCase())} /></FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                  <FormField control={form.control} name="gstNo" render={({ field }) => (
                    <FormItem><FieldRow label="GST No." required>
                      <FormControl><Input placeholder="22ABCDE1234F1Z5" className="h-10 font-mono tracking-wider" {...field} onChange={(e) => field.onChange(e.target.value.toUpperCase())} /></FormControl>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                  <FormField control={form.control} name="msmeStatus" render={({ field }) => (
                    <FormItem><FieldRow label="MSME Status" required>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger className="h-10"><SelectValue placeholder="Select MSME category" /></SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="micro">Micro Enterprise</SelectItem>
                          <SelectItem value="small">Small Enterprise</SelectItem>
                          <SelectItem value="medium">Medium Enterprise</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FieldRow></FormItem>
                  )} />
                </div>

                <div className="px-6 pb-6">
                  <Button type="submit" size="lg" className="w-full h-11 font-bold uppercase tracking-wider" disabled={isLoading}>
                    {isLoading ? "Submitting…" : "Submit Registration"}
                  </Button>
                </div>
              </form>
            </Form>
          </div>

          <p className="text-sm text-muted-foreground text-center mt-6">
            Already have an account?{" "}
            <Link to="/login" className="text-primary font-semibold hover:underline">Sign in</Link>
          </p>
        </div>
      </main>
    </PublicLayout>
  );
};

export default Register;
