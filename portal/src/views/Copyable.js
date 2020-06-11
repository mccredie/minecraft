
import { connect } from "react-redux";
import { toast } from "~/toast/operations";
import CopyableComponent from "~/components/Copyable";

export default connect(null, {onCopy: () => toast("Text copied to your clipboard", 2000)})(CopyableComponent);
